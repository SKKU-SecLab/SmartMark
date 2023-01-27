
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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

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

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
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

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// MIT
pragma solidity >=0.8.9 <0.9.10;


contract SQUARMS is ERC20Burnable, Ownable {

    uint256 public MAX_WALLET_STAKED = 5;
    uint256 public EMISSIONS_RATE =11580000000000;
    uint256 public CLAIM_END_TIME;
    uint256 public STAKE_DURATION = 0;
    address nullAddress = address(0);
    address public squarmiesAddress;
    bool public paused = false;
    bool public isLate = false;

    mapping(uint256 => uint256) internal tokenIdToTimeStamp;
    mapping(uint256 => address) internal tokenIdToStaker;
    mapping(address => uint256) internal addressToTimeStamp;
    mapping(address => uint256[]) internal stakerToTokenIds;


    constructor() ERC20("Squarms", "SQUARMS") {

        _mint( msg.sender, 15000 ether);
    }

    function getTokensStaked(address staker)
        public
        view
        returns (uint256[] memory)
    {
        return stakerToTokenIds[staker];
    }

    function getTokenTime (uint256 tokenId) public view 
    returns (uint256) {
        return tokenIdToTimeStamp[tokenId];
    }

    function getTimeStaked (address squarfam) public view returns (uint256) {
        return addressToTimeStamp[squarfam];
    }

    function getTimeLeft (address squarfam) public view returns (uint256) {
        return addressToTimeStamp[squarfam] + STAKE_DURATION;
    }

       function getStaker(uint256 tokenId) public view returns (address) {
        return tokenIdToStaker[tokenId];
    }

     function getAllRewards(address squarfam) public view returns (uint256) {
        uint256[] memory tokenIds = stakerToTokenIds[squarfam];
        uint256 totalRewards = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            totalRewards =
                totalRewards +
                ((block.timestamp - tokenIdToTimeStamp[tokenIds[i]]) *
                    EMISSIONS_RATE);
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
            "Squarmies is not staked!"
        );

        uint256 secondsStaked = block.timestamp - tokenIdToTimeStamp[tokenId];

        return secondsStaked * EMISSIONS_RATE;
    }



    function stakeSquarmies(uint256[] memory tokenIds) public {
        require(
            stakerToTokenIds[msg.sender].length + tokenIds.length <=
                MAX_WALLET_STAKED,
            "You've reached max staked"
        );
        require(!paused);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                IERC721(squarmiesAddress).ownerOf(tokenIds[i]) == msg.sender &&
                    tokenIdToStaker[tokenIds[i]] == nullAddress, "You dont own this token");

            IERC721(squarmiesAddress).transferFrom(
                msg.sender,
                address(this),
                tokenIds[i]
            );

            stakerToTokenIds[msg.sender].push(tokenIds[i]);

            tokenIdToTimeStamp[tokenIds[i]] = block.timestamp;
            addressToTimeStamp[msg.sender] = block.timestamp;
            tokenIdToStaker[tokenIds[i]] = msg.sender;
        }
    }

    function unstakeAllSquarmies() public {
        require(stakerToTokenIds[msg.sender].length > 0, "Must have at least > 1 staked");
       require(addressToTimeStamp[msg.sender] >= addressToTimeStamp[msg.sender]+ STAKE_DURATION);
       require(!paused);

        uint256 totalRewards = 0;


        for (uint256 i = stakerToTokenIds[msg.sender].length; i > 0; i--) {
            uint256 tokenId = stakerToTokenIds[msg.sender][i - 1];

                   IERC721(squarmiesAddress).transferFrom(
                address(this),
                msg.sender,
                tokenId
            );

            totalRewards = totalRewards + ((block.timestamp - tokenIdToTimeStamp[tokenId]) * EMISSIONS_RATE);
            removeTokenIdFromStaker(msg.sender, tokenId);
            addressToTimeStamp[msg.sender] = block.timestamp;

             tokenIdToStaker[tokenId] = nullAddress;
             _mint(msg.sender, totalRewards);

              }
    }

  function unstakeLateSquarmies() public {
        require(stakerToTokenIds[msg.sender].length > 0, "Must have at least > 1 staked");
       require(isLate);

        uint256 totalRewards = 0;


        for (uint256 i = stakerToTokenIds[msg.sender].length; i > 0; i--) {
            uint256 tokenId = stakerToTokenIds[msg.sender][i - 1];

                   IERC721(squarmiesAddress).transferFrom(
                address(this),
                msg.sender,
                tokenId
            );

            totalRewards = totalRewards + ((CLAIM_END_TIME - tokenIdToTimeStamp[tokenId]) * EMISSIONS_RATE);
            removeTokenIdFromStaker(msg.sender, tokenId);
            addressToTimeStamp[msg.sender] = block.timestamp;

             tokenIdToStaker[tokenId] = nullAddress;
             _mint(msg.sender, totalRewards);
              }
    }

    function claimAll() public {
        require(block.timestamp < CLAIM_END_TIME, "Claim cycle has ended");
       require(addressToTimeStamp[msg.sender] >= addressToTimeStamp[msg.sender]+ STAKE_DURATION);
        require(!paused);

        uint256[] memory tokenIds = stakerToTokenIds[msg.sender];
        uint256 totalRewards = 0;
        
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                tokenIdToStaker[tokenIds[i]] == msg.sender,
                "Squarmies is not yours to claim"
            );

              totalRewards = totalRewards + ((block.timestamp - tokenIdToTimeStamp[tokenIds[i]]) * EMISSIONS_RATE);
             tokenIdToTimeStamp[tokenIds[i]] = block.timestamp;
           addressToTimeStamp[msg.sender] = block.timestamp;
         
        } _mint(msg.sender, totalRewards);
    }

  function claimAllLate() public {
       require(isLate);

        uint256[] memory tokenIds = stakerToTokenIds[msg.sender];
        uint256 totalRewards = 0;
  
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require( tokenIdToStaker[tokenIds[i]] == msg.sender,"Squarmies is not yours to claim");
              totalRewards = totalRewards + ((CLAIM_END_TIME - tokenIdToTimeStamp[tokenIds[i]]) * EMISSIONS_RATE);
             tokenIdToTimeStamp[tokenIds[i]] = block.timestamp;
           addressToTimeStamp[msg.sender] = block.timestamp;
        }
         _mint(msg.sender, totalRewards);
    }

    function setMaxStaked (uint _stakeMax) public onlyOwner {
       MAX_WALLET_STAKED = _stakeMax;
    }

    function setStakeDuration (uint _stakeDuration) public onlyOwner {
        STAKE_DURATION = _stakeDuration * 1 days;
    }

 function setLateBool(bool _state) public onlyOwner {
        isLate = _state;
    }

     function setPaused(bool _state) public onlyOwner {
         paused = _state;
    }

function setClaimCycle (uint256 _claimTime) public onlyOwner {
    CLAIM_END_TIME = _claimTime;
    }

    function setEmission (uint256 _rate) public onlyOwner {
        EMISSIONS_RATE = _rate; 
        }

    function setAddress(address _squarmiesAddress) public onlyOwner
    { squarmiesAddress = _squarmiesAddress; 
    }

 function emergencyWithdraw() public {
        require(stakerToTokenIds[msg.sender].length > 0, "Must have at least > 1 staked");
        for (uint256 i = stakerToTokenIds[msg.sender].length; i > 0; i--) {
            uint256 tokenId = stakerToTokenIds[msg.sender][i - 1];

                   IERC721(squarmiesAddress).transferFrom(
                address(this),
                msg.sender,
                tokenId
            );

            removeTokenIdFromStaker(msg.sender, tokenId);
            addressToTimeStamp[msg.sender] = block.timestamp;
             tokenIdToStaker[tokenId] = nullAddress;

              }
              
 } 

     function removeSquarmies(address staker, uint256 index) internal {
        if (index >= stakerToTokenIds[staker].length) return;

        for (uint256 i = index; i < stakerToTokenIds[staker].length - 1; i++) {
            stakerToTokenIds[staker][i] = stakerToTokenIds[staker][i + 1];
        }
        stakerToTokenIds[staker].pop();
    }

    function removeTokenIdFromStaker(address staker, uint256 tokenId) internal {
        for (uint256 i = 0; i < stakerToTokenIds[staker].length; i++) {
            if (stakerToTokenIds[staker][i] == tokenId) {
                removeSquarmies(staker, i);
            }
        }
    }

}