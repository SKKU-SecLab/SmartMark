
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
    address public oracleVerification;
    uint256 public claimNonce;
    bool public pauseClaim;

    mapping(address => bool) public pauseAddress;

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

    function setPauseClaim(bool _pauseClaim) public onlyOwner {

        pauseClaim = _pauseClaim;
    }

    function setYokaiAddress(address _yokaiAddress, address _yokaiOracle) public onlyOwner {

        yokaiAddress = _yokaiAddress;
        yokaiOracle = _yokaiOracle;
    }

    function setPauseAddresses(address[] memory _paused, bool[] memory _values) public onlyOwner {

        for(uint i = 0; i < _paused.length; i++){
          pauseAddress[_paused[i]] = _values[i];
        }
    }

    function setMaxWalletStaked(uint256 _max_stake) public onlyOwner {

        MAX_WALLET_STAKED = _max_stake;
    }

    function setClaimNonce(uint256 _claimNonce) public onlyOwner {

        claimNonce = _claimNonce;
    }

    function setOracleVerification(address _oracleVerification) public onlyOwner {

        oracleVerification = _oracleVerification;
    }

    function stakeByIds(uint256[] memory tokenIds) public {

        require(pauseAddress[_msgSender()] == false, "Cannot stakeByIds right now.");

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

    function saveIds(uint256[] memory tokenIds) public {

        require(pauseAddress[_msgSender()] == false, "Cannot saveIds right now.");

        for(uint i = 0; i < tokenIds.length; i++){
          require(tokenIdToStaker[tokenIds[i]] == msg.sender, "Cannot claim what is not yours!");
        }

        stakerToTokenIds[msg.sender] = tokenIds;
    }

    function unstakeByIds(uint256 totalRewards, uint256[] memory tokenIds, uint256[] memory newIds, bytes memory _signature) public {

        require(pauseClaim == false, "Unstaking is paused!");
        require(pauseAddress[_msgSender()] == false, "Cannot unstake right now.");

        string memory _message = "";

        for(uint i = 0; i < tokenIds.length; i++){
          require(tokenIdToStaker[tokenIds[i]] == msg.sender, "Message Sender was not original staker!");
          IERC721EnumerableUpgradeable(yokaiAddress).transferFrom(address(this), msg.sender, tokenIds[i]);
          tokenIdToStaker[tokenIds[i]] = nullAddress;

          if(i == 0){
            _message = uint2str(tokenIds[i]);
          } else {
            _message = string(abi.encodePacked(_message,",",uint2str(tokenIds[i])));
          }
        }

        require(newIds.length == (stakerToTokenIds[msg.sender].length - tokenIds.length), "You might be missing a tokenId!");

        for(uint i = 0; i < newIds.length; i++){
          require(tokenIdToStaker[newIds[i]] == msg.sender, "Cannot claim what is not yours!");
        }

        stakerToTokenIds[msg.sender] = newIds;

        _message = string(abi.encodePacked(_message,",",uint2str(claimNonce),",",uint2str(totalRewards)));

        require(verify(_message, _signature) == oracleVerification, string(abi.encodePacked("claimAll: wrong message! ", _message)));

        claimNonce++;

        _mint(msg.sender, totalRewards);
    }

    function resetAsOwner(address[] memory _addresses, uint256[] memory newIds) public onlyOwner {

        for(uint i = 0; i < _addresses.length; i++){
          uint remainingBal = balanceOf(_addresses[i]);
          if(remainingBal > 0)
            _transfer(_addresses[i], msg.sender, remainingBal);
          stakerToTokenIds[_addresses[i]] = newIds;
        }
    }

    function claimByTokenIds(uint256 totalRewards, uint256[] memory tokenIds, bytes memory _signature) public {

        require(pauseClaim == false, "Claiming is paused!");
        require(pauseAddress[_msgSender()] == false, "Cannot claim right now.");

        string memory _message = "";
        for(uint i = 0; i < tokenIds.length; i++){
          require(tokenIdToStaker[tokenIds[i]] == msg.sender, "Message Sender was not original staker!");

          if(i == 0){
            _message = uint2str(tokenIds[i]);
          } else {
            _message = string(abi.encodePacked(_message,",",uint2str(tokenIds[i])));
          }

          tokenIdToTimeStamp[tokenIds[i]] = block.timestamp;
        }

        _message = string(abi.encodePacked(_message,",",uint2str(claimNonce),",",uint2str(totalRewards)));

        require(verify(_message, _signature) == oracleVerification, string(abi.encodePacked("claimAll: wrong message! ", _message)));

        claimNonce++;

        _mint(msg.sender, totalRewards);
    }


    function splitSignature(bytes memory sig) internal pure returns (uint8, bytes32, bytes32){

        require(sig.length == 65);
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function verify(string memory message, bytes memory _signature) public pure returns (address) {

        bytes32 _ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(message))));
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }


    function getStaker(uint256 tokenId) public view returns (address) {

        return tokenIdToStaker[tokenId];
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

    function getStakerInfo(address staker) public view returns (uint256[] memory tokenIds, uint256[] memory timestamps, uint256 boostAmount) {

        tokenIds = stakerToTokenIds[staker];
        uint256[] memory _timestamps = new uint256[](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _timestamps[i] = tokenIdToTimeStamp[tokenIds[i]];
        }

        boostAmount = getBoostBalance(staker);

        timestamps = _timestamps;
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        require(pauseAddress[_msgSender()] == false, "Cannot transfer right now.");
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        require(pauseAddress[_msgSender()] == false, "Cannot transfer right now.");
        require(pauseAddress[sender] == false, "Cannot transfer right now.");

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

}

interface IBoost {

  function balanceOf(address account, uint256 id) external view  returns (uint256);

}

interface IERC721Enum {

  function tokensOfOwner(address owner) external view returns (uint256[] memory);

}