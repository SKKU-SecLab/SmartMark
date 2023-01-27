
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

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

    uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20BurnableUpgradeable is Initializable, ContextUpgradeable, ERC20Upgradeable {
    function __ERC20Burnable_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC20Burnable_init_unchained();
    }

    function __ERC20Burnable_init_unchained() internal onlyInitializing {
    }
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
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


library SafeMathUpgradeable {

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

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT
pragma solidity ^0.8.10;


contract YohToken is ERC20BurnableUpgradeable, OwnableUpgradeable {

    using SafeMathUpgradeable for uint256;

    uint256 public MAX_WALLET_STAKED;

    uint256 public MAX_MULTIPLIER;

    address nullAddress;
    address public yokaiAddress;
    address public yokaiOracle;

    mapping(uint256 => uint256) internal tokenIdToTimeStamp;
    mapping(uint256 => address) internal tokenIdToStaker;
    mapping(address => uint256[]) internal stakerToTokenIds;

    address public boostAddress;

    function initialize() public initializer {

        __ERC20_init("Yoh Token", "YOH");
        __ERC20Burnable_init();
        __Ownable_init();
        nullAddress = 0x0000000000000000000000000000000000000000;
        MAX_MULTIPLIER = 175;
        MAX_WALLET_STAKED = 100;
    }

    function setBoostAddress(address _boostAddress) public onlyOwner {

        boostAddress = _boostAddress;
    }

    function setYokaiAddress(address _yokaiAddress, address _yokaiOracle) public onlyOwner {

        yokaiAddress = _yokaiAddress;
        yokaiOracle = _yokaiOracle;
    }

    function setMaxWalletStaked(uint256 _max_stake) public onlyOwner {

        MAX_WALLET_STAKED = _max_stake;
    }

    function getTokensStaked(address staker) public view returns (uint256[] memory) {

        return stakerToTokenIds[staker];
    }

    function getBoostBalance(address staker) public view returns (uint256 boostAmount) {

        boostAmount = 0;
        if(boostAddress != address(0)){
          boostAmount = IBoost(boostAddress).balanceOf(staker, 1);
        }
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

        require(stakerToTokenIds[msg.sender].length + tokenIds.length <= MAX_WALLET_STAKED,
            "You are staking too many!"
        );

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                IERC721EnumerableUpgradeable(yokaiAddress).ownerOf(tokenIds[i]) == msg.sender &&
                    tokenIdToStaker[tokenIds[i]] == nullAddress,
                "Token must be stakable by you!"
            );

            IERC721EnumerableUpgradeable(yokaiAddress).transferFrom(msg.sender, address(this), tokenIds[i]);

            stakerToTokenIds[msg.sender].push(tokenIds[i]);

            tokenIdToTimeStamp[tokenIds[i]] = block.timestamp;
            tokenIdToStaker[tokenIds[i]] = msg.sender;
        }
    }

    function unstakeByIds(uint256[] memory tokenIds, bytes32[][] memory proof) public {

        uint256 totalRewards = 0;

        uint boostAmount = getBoostBalance(msg.sender);
        uint totalStakedAmount = stakerToTokenIds[msg.sender].length;


        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIdToStaker[tokenIds[i]] == msg.sender, "Message Sender was not original staker!");

            IERC721EnumerableUpgradeable(yokaiAddress).transferFrom(address(this), msg.sender, tokenIds[i]);

            totalRewards = totalRewards + getRewards(tokenIdToTimeStamp[tokenIds[i]], tokenIds[i], proof[i], totalStakedAmount, boostAmount);

            removeTokenIdFromStaker(msg.sender, tokenIds[i]);

            tokenIdToStaker[tokenIds[i]] = nullAddress;
        }

        _mint(msg.sender, totalRewards);
    }

    function claimByTokenIds(uint256[] memory tokenIds, bytes32[][] memory proof) public {

        uint256 totalRewards = 0;
        uint boostAmount = getBoostBalance(msg.sender);
        uint totalStakedAmount = stakerToTokenIds[msg.sender].length;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIdToStaker[tokenIds[i]] == msg.sender, "Token is not claimable by you!");
            totalRewards = totalRewards + getRewards(tokenIdToTimeStamp[tokenIds[i]], tokenIds[i], proof[i], totalStakedAmount, boostAmount);
            tokenIdToTimeStamp[tokenIds[i]] = block.timestamp;
        }

        _mint(msg.sender, totalRewards);
    }


    function claimAll(bytes32[][] memory proof) public {

        uint256[] memory tokenIds = stakerToTokenIds[msg.sender];
        uint256 totalRewards = 0;

        uint boostAmount = getBoostBalance(msg.sender);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIdToStaker[tokenIds[i]] == msg.sender, "Token is not claimable by you!");
            totalRewards = totalRewards + getRewards(tokenIdToTimeStamp[tokenIds[i]], tokenIds[i], proof[i], tokenIds.length, boostAmount);
            tokenIdToTimeStamp[tokenIds[i]] = block.timestamp;
        }

        _mint(msg.sender, totalRewards);
    }

    function getAllMultipliers(address staker, bytes32[][] memory proof) external view returns (uint[] memory, uint[] memory, uint[] memory, uint[] memory) {

        uint[] memory tokenIds = stakerToTokenIds[staker];
        IYokaiOracle oracle = IYokaiOracle(yokaiOracle);
        uint[] memory multiplier = new uint[](tokenIds.length);
        uint[] memory rarity = new uint[](tokenIds.length);
        uint[] memory rewards = new uint[](tokenIds.length);

        uint boostAmount = getBoostBalance(staker);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint delta_time = (block.timestamp - tokenIdToTimeStamp[tokenIds[i]]);
            multiplier[i] = getMultiplier(delta_time, tokenIds.length, boostAmount);

            if(oracle.isSpecialRarity(tokenIds[i], proof[i])){
              rarity[i] = 4;
            } else if(oracle.isMythicRarity(tokenIds[i], proof[i])){
              rarity[i] = 3;
            } else if(oracle.isLegendaryRarity(tokenIds[i], proof[i])){
              rarity[i] = 2;
            } else if(oracle.isRareRarity(tokenIds[i], proof[i])){
              rarity[i] = 1;
            } else {
              rarity[i] = 0;
            }

            rewards[i] = getRewards(tokenIdToTimeStamp[tokenIds[i]], tokenIds[i], proof[i], tokenIds.length, boostAmount);
        }

        return (tokenIds, multiplier, rarity, rewards);

    }

    function getAllRewards(address staker, bytes32[][] memory proof) external view returns (uint) {

        uint[] memory tokenIds = stakerToTokenIds[staker];
        uint rewards;

        uint boostAmount = getBoostBalance(staker);
        uint totalStakedAmount = stakerToTokenIds[staker].length;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            rewards += getRewards(tokenIdToTimeStamp[tokenIds[i]], tokenIds[i], proof[i], boostAmount, totalStakedAmount);
        }

        return rewards;
    }

    function getRewardsByTokenId(uint256 tokenId, bytes32[] memory proof) public view returns (uint256) {

        require(tokenIdToStaker[tokenId] != nullAddress, "Token is not staked!");

        uint boostAmount = getBoostBalance(tokenIdToStaker[tokenId]);
        uint totalStakedAmount = stakerToTokenIds[tokenIdToStaker[tokenId]].length;

        return getRewards(tokenIdToTimeStamp[tokenId], tokenId, proof, totalStakedAmount, boostAmount);
    }

    function getStaker(uint256 tokenId) public view returns (address) {

        return tokenIdToStaker[tokenId];
    }

    function getRewards(uint256 tokenTimestamp, uint tokenID, bytes32[] memory proof, uint totalStakedAmount, uint boostAmount) public view returns (uint256){

      IYokaiOracle oracle = IYokaiOracle(yokaiOracle);

      uint emission = 0;

      if(oracle.isSpecialRarity(tokenID, proof)){
        emission = 277e13;
      } else if(oracle.isMythicRarity(tokenID, proof)){
        emission = 230e13;
      } else if(oracle.isLegendaryRarity(tokenID, proof)){
        emission = 185e13;
      } else if(oracle.isRareRarity(tokenID, proof)){
        emission = 140e13;
      } else {
        emission = 93e13;
      }

      uint delta_time = (block.timestamp - tokenTimestamp);
      return delta_time.mul(emission).mul(getMultiplier(delta_time, totalStakedAmount, boostAmount)).div(100);
    }

    function getMultiplier(uint delta_time, uint totalStakedAmount, uint boostAmount) internal view returns (uint) {

      uint multiplier = (60 * 60 * 24 * 120);


      if(boostAmount > 0){
        uint256 totalBonus = 24 * 60 * 60 * 12 * boostAmount / totalStakedAmount;
        delta_time += totalBonus;
      }


      uint multi = get_with_bound(delta_time.mul(100).div(multiplier).add(100), MAX_MULTIPLIER);

      if(multi < 100)
        multi = 100;

      return multi;
    }
    function get_with_bound(uint value, uint bound) public pure returns (uint) {

          if (value < bound) {
              return value;
          } else {
              return bound;
          }
      }

}

interface IYokaiOracle {

  function isCommonRarity(uint id, bytes32[] memory _merkleProof) external view returns (bool);

  function isRareRarity(uint id, bytes32[] memory _merkleProof) external view returns (bool);

  function isLegendaryRarity(uint id, bytes32[] memory _merkleProof) external view returns (bool);

  function isMythicRarity(uint id, bytes32[] memory _merkleProof) external view returns (bool);

  function isSpecialRarity(uint id, bytes32[] memory _merkleProof) external view returns (bool);

}

interface IBoost {

  function balanceOf(address account, uint256 id) external view  returns (uint256);

}