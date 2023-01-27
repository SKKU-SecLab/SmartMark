
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
}// MIT

pragma solidity ^0.8.7;


interface ISpiritOrbPetsv0 is IERC721, IERC721Enumerable {

}

interface IOldCareToken is IERC20 {
  function _emissionStart() external view returns (uint256);
  function lastClaim(uint256 tokenIndex) external view returns (uint256);
}

contract CareToken is ERC20 {

  address public _owner;
  address[] public _approvedMinters;

  bool public _closedMintToOwner = false;
  bool public _freezeApprovedMintersList = false;

  ISpiritOrbPetsv0 public SOPV0Contract;
  IOldCareToken public OldCareToken;
  uint256 public INITIAL_ALLOTMENT = 100 * (10 ** 18);

  uint256 public _emissionStart = 0;
  uint256 public _emissionEnd = 0;
  uint256 public _emissionPerDay = 10 * (10 ** 18);

  mapping(uint256 => uint256) private _lastClaim;

  constructor() ERC20('Spirit Orb Pets Care Token', 'CARE') {
    _mint(msg.sender, 40000 * 10 ** 18);
    _owner = msg.sender;
  }

  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  function mint(uint256 amount) external onlyOwner {
    require(!_closedMintToOwner, "Minting to owner is permanently closed.");
    _mint(msg.sender, amount * 10 ** 18);
  }

  function burn(address account, uint256 amount) external {
    require(_approvedMinters.length > 0, "There are no approved contracts yet.");
    require(isApproved(msg.sender), "Address is not approved to burn.");
    super._burn(account, amount);
  }

  function closeMintToOwner() external onlyOwner {
    _closedMintToOwner = true;
  }

  function addApprovedContract(address addr) external onlyOwner {
    require(_freezeApprovedMintersList == false, "Once frozen, no more contracts can be added or removed.");
    _approvedMinters.push(addr);
  }

  function removeApprovedContract(uint index) external onlyOwner {
    require(_freezeApprovedMintersList == false, "Once frozen, no more contracts can be added or removed.");
    _approvedMinters[index] = _approvedMinters[_approvedMinters.length - 1];
    _approvedMinters.pop();
  }

  function getApprovedContractList() external view returns (address[] memory) {
    return _approvedMinters;
  }

  function freezeApprovedMinters() external onlyOwner {
    require(_freezeApprovedMintersList == false, "Once frozen, no more contracts can be added or removed.");
    _freezeApprovedMintersList = true;
  }

  function isApproved(address addr) internal view returns (bool) {
    bool approved = false;
    for (uint i = 0; i < _approvedMinters.length; i++) {
      if (_approvedMinters[i] == addr) approved = true;
    }
    return approved;
  }

  function mintToApprovedContract(uint256 amount, address mintToAddress) external {
    require(_approvedMinters.length > 0, "There are no approved contracts yet.");
    require(isApproved(msg.sender), "Address is not approved to mint.");

    _mint(mintToAddress, amount);
  }

  function setOwner(address addr) external onlyOwner {
    _owner = addr;
  }

  function setSOPV0Contract(address addr) external onlyOwner {
    SOPV0Contract = ISpiritOrbPetsv0(addr);
  }

  function setOldCareTokenContract(address addr) external onlyOwner {
    OldCareToken = IOldCareToken(addr);
  }

  function beginEmissionOfTokens() external onlyOwner {
    require(_emissionStart == 0 && _emissionEnd == 0, "Emission timestamps already set!");
    _emissionStart = OldCareToken._emissionStart();
    _emissionEnd = _emissionStart + (10 * 365 days) + 2 days; // +2 for leap years
  }

  function lastClaim(uint256 tokenIndex) public view returns (uint256) {
    require(SOPV0Contract.ownerOf(tokenIndex) != address(0));
    require(tokenIndex < SOPV0Contract.totalSupply(), "Token index is higher than total collection count.");

    uint256 oldClaim = OldCareToken.lastClaim(tokenIndex);
    uint256 lastClaimed = oldClaim >= uint256(_lastClaim[tokenIndex]) ? oldClaim : uint256(_lastClaim[tokenIndex]);
    lastClaimed = lastClaimed != 0 ? lastClaimed : _emissionStart;

    return lastClaimed;
  }

  function accumulated(uint256 tokenIndex) public view returns (uint256) {
      require(_emissionStart != 0 && _emissionEnd != 0, "Emission has not started yet");
      require(SOPV0Contract.ownerOf(tokenIndex) != address(0), "Owner cannot be 0 address");
      require(tokenIndex < SOPV0Contract.totalSupply(), "Token index is higher than total collection count.");

      uint256 lastClaimed = lastClaim(tokenIndex);

      if (lastClaimed >= _emissionEnd) return 0;

      uint256 accumulationPeriod = block.timestamp < _emissionEnd ? block.timestamp : _emissionEnd; // Getting the min value of both
      uint256 totalAccumulated = (((accumulationPeriod - lastClaimed) * _emissionPerDay) / 1 days);

      if (lastClaimed == _emissionStart) {
        totalAccumulated = totalAccumulated + INITIAL_ALLOTMENT;
      }

      return totalAccumulated;
  }

  function claim(uint256[] memory tokenIndices) public returns (uint256) {
      require(_emissionStart != 0 && _emissionEnd != 0, "Emission has not started yet");

      uint256 totalClaimQty = 0;
      for (uint i = 0; i < tokenIndices.length; i++) {
          require(tokenIndices[i] < SOPV0Contract.totalSupply(), "NFT at index has not been minted yet");
          for (uint j = i + 1; j < tokenIndices.length; j++) {
              require(tokenIndices[i] != tokenIndices[j], "Duplicate token index");
          }

          uint tokenIndex = tokenIndices[i];
          require(SOPV0Contract.ownerOf(tokenIndex) == msg.sender, "Sender is not the owner");

          uint256 claimQty = accumulated(tokenIndex);
          if (claimQty != 0) {
              totalClaimQty = totalClaimQty + claimQty;
              _lastClaim[tokenIndex] = block.timestamp;
          }
      }

      require(totalClaimQty != 0, "No accumulated CARE");
      _mint(msg.sender, totalClaimQty);
      return totalClaimQty;
  }

}