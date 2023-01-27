
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

abstract contract Ownable is Context {
    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyPendingOwner() {
        require(pendingOwner() == _msgSender(), "Ownable: caller is not the pending owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _pendingOwner = newOwner;
    }

    function claimOwnership() external onlyPendingOwner {
        _owner = _pendingOwner;
        _pendingOwner = address(0);
        emit OwnershipTransferred(_owner, _pendingOwner);
    }
}// MIT

pragma solidity ^0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}//Unlicense
pragma solidity ^0.8.0;


contract ChainIdValidators is Ownable {

    using ECDSA for bytes32;

    uint256[] public chainIds;

    function addChainId(uint256 _chainId) external onlyOwner {

        (bool found,) = indexOfChainId(_chainId);
        require(!found, 'ChainId already added');
        chainIds.push(_chainId);
    }

    function removeChainId(uint256 _chainId) external onlyOwner {

        (bool found, uint256 index) = indexOfChainId(_chainId);
        require(found, 'ChainId not found');
        if (chainIds.length > 1) {
            chainIds[index] = chainIds[chainIds.length - 1];
        }
        chainIds.pop();
    }

    function getListChainIds() public view returns (uint256[] memory) {

        return chainIds;
    }

    function indexOfChainId(uint256 _chainId) public view returns (bool found, uint256 index) {

        for (uint256 i = 0; i < chainIds.length; i++) {
            if (chainIds[i] == _chainId) {
                return (true, i);
            }
        }
        return (false, 0);
    }
}// MIT

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


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

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

        return 8;
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

function _transfer(address sender, address recipient, uint256 amount) internal virtual {

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
unchecked {
_balances[account] = accountBalance - amount;
_totalSupply -= amount;
}

emit Transfer(account, address(0), amount);
}

function _approve(address owner, address spender, uint256 amount) internal virtual {

require(owner != address(0), "ERC20: approve from the zero address");
require(spender != address(0), "ERC20: approve to the zero address");

_allowances[owner][spender] = amount;
emit Approval(owner, spender, amount);
}

function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

}// MIT
pragma solidity ^0.8.0;


interface IERC677 is IERC20 {
    function transferAndCall(
        address to,
        uint256 value,
        bytes memory data
    ) external returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);
}// MIT
pragma solidity ^0.8.0;

interface IERC677Receiver {
    function onTokenTransfer(address _sender, uint _value, bytes memory _data) external;
}//Unlicense
pragma solidity ^0.8.0;


contract Validators is ChainIdValidators {
    using ECDSA for bytes32;

    address[] public bridgeValidators;

    function addBridgeValidator(address _validator) external onlyOwner {
        (bool found,) = indexOfBridgeValidator(_validator);
        require(!found, 'Validator already added');
        bridgeValidators.push(_validator);
    }

    function removeBridgeValidator(address _validator) external onlyOwner {
        (bool found, uint index) = indexOfBridgeValidator(_validator);
        require(found, 'Validator not found');
        if (bridgeValidators.length > 1) {
            bridgeValidators[index] = bridgeValidators[bridgeValidators.length - 1];
        }
        bridgeValidators.pop();
    }

    function getListBridgeValidators() public view returns (address[] memory) {
        return bridgeValidators;
    }

    function indexOfBridgeValidator(address _validator) public view returns (bool found, uint index) {
        for (uint i = 0; i < bridgeValidators.length; i++) {
            if (bridgeValidators[i] == _validator) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function checkSignatures(bytes32 _messageHash, bytes[] memory _signatures) public view returns (bool) {
        require(bridgeValidators.length > 0, 'Validators not added');
        require(_signatures.length == bridgeValidators.length, 'The number of signatures does not match the number of validators');
        bool[] memory markedValidators = new bool[](bridgeValidators.length);
        for (uint i = 0; i < _signatures.length; i++) {
            address extractedAddress = _messageHash.toEthSignedMessageHash().recover(_signatures[i]);
            (bool found, uint index) = indexOfBridgeValidator(extractedAddress);
            if (found && !markedValidators[index]) {
                markedValidators[index] = true;
            } else {
                return false;
            }
        }
        return true;
    }
}// MIT
pragma solidity ^0.8.0;


contract CguToken is ERC20, IERC677, Validators {

    event Minted(address indexed _from, uint256 indexed _fromChainId, uint256 indexed _lockId, uint256 _amount);
    event Burned(address indexed _from, uint256 indexed _toChainId, uint256 indexed _burnId, uint256 _amount);

    uint256 public lastBurnId;
    mapping(uint256 =>  mapping(uint256 => bool)) public lockIdsUsed;

    constructor(
        string memory tokenName,
        string memory tokenSymbol
    ) ERC20(tokenName, tokenSymbol) {}

    function mint (uint256 _fromChainId, uint256 _lockId, uint256 _amount, bytes[] memory _signatures) external {
        require(!lockIdsUsed[_fromChainId][_lockId], "Lock id already used");
        bytes32 messageHash = keccak256(abi.encodePacked(_msgSender(), _fromChainId, block.chainid, _lockId, _amount));
        require(checkSignatures(messageHash, _signatures), "Incorrect signature(s)");
        lockIdsUsed[_fromChainId][_lockId] = true;
        _mint(_msgSender(), _amount);
        emit Minted(_msgSender(), _fromChainId, _lockId, _amount);
    }

    function burn (uint256 _toChainId, uint256 _amount) external {
        require(_amount > 0, "The amount of the lock must not be zero");
        (bool found,) = indexOfChainId(_toChainId);
        require(found, "ChainId not allowed");
        _burn(_msgSender(), _amount);
        lastBurnId++;
        emit Burned(_msgSender(), _toChainId, lastBurnId, _amount);
    }

    function transferAndCall(address _to, uint _value, bytes memory _data) public override returns (bool success)
    {
        transfer(_to, _value);
        emit Transfer(_msgSender(), _to, _value, _data);
        if (isContract(_to)) {
            contractFallback(_to, _value, _data);
        }
        return true;
    }

    function contractFallback(address _to, uint _value, bytes memory _data) private
    {
        IERC677Receiver receiver = IERC677Receiver(_to);
        receiver.onTokenTransfer(_msgSender(), _value, _data);
    }

    function isContract(address _addr) private view returns (bool hasCode)
    {
        uint length;
        assembly { length := extcodesize(_addr) }
        return length > 0;
    }

}