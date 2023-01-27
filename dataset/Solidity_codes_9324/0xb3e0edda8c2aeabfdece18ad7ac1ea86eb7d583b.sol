

pragma solidity >=0.6.0 <0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}


pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{ value: amount }("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
}


pragma solidity >=0.6.0 <0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}


pragma solidity >=0.6.0 <0.8.0;

contract BeaconProxy is Proxy {

    bytes32 private constant _BEACON_SLOT =
        0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    constructor(address beacon, bytes memory data) public payable {
        assert(
            _BEACON_SLOT ==
                bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1)
        );
        _setBeacon(beacon, data);
    }

    function _beacon() internal view virtual returns (address beacon) {

        bytes32 slot = _BEACON_SLOT;
        assembly {
            beacon := sload(slot)
        }
    }

    function _implementation()
        internal
        view
        virtual
        override
        returns (address)
    {

        return IBeacon(_beacon()).implementation();
    }

    function _setBeacon(address beacon, bytes memory data) internal virtual {

        require(
            Address.isContract(beacon),
            "BeaconProxy: beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(beacon).implementation()),
            "BeaconProxy: beacon implementation is not a contract"
        );
        bytes32 slot = _BEACON_SLOT;

        assembly {
            sstore(slot, beacon)
        }

        if (data.length > 0) {
            Address.functionDelegateCall(
                _implementation(),
                data,
                "BeaconProxy: function call failed"
            );
        }
    }
}


pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}


pragma solidity >=0.6.0 <0.8.0;

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
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

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}


pragma solidity =0.7.6;

interface ILiquidVestingToken {
    enum AddType {
        MerkleTree,
        Airdrop
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _owner,
        address _factory,
        address _redeemToken,
        uint256 _activationTimestamp,
        uint256 _redeemTimestamp,
        AddType _type
    ) external;

    function overrideFee(uint256 _newFee) external;

    function addRecipient(address _recipient, uint256 _amount) external;

    function addRecipients(
        address[] memory _recipients,
        uint256[] memory _amounts
    ) external;

    function addMerkleRoot(
        bytes32 _merkleRoot,
        uint256 _totalAmount,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function claimTokensByMerkleProof(
        bytes32[] memory _proof,
        uint256 _rootId,
        address _recipient,
        uint256 _amount
    ) external;

    function claimProjectTokensByFeeCollector() external;

    function redeem(address _recipient, uint256 _amount) external;
}


pragma solidity =0.7.6;
pragma abicoder v2;

interface ILiquidVestingTokenFactory {
    function merkleRootSigner() external view returns (address);

    function feeCollector() external view returns (address);

    function fee() external view returns (uint256);

    function getMinFee() external pure returns (uint256);

    function getMaxFee() external pure returns (uint256);

    function setMerkleRootSigner(address _newMerkleRootSigner) external;

    function setFeeCollector(address _newFeeCollector) external;

    function setFee(uint256 _fee) external;

    function implementation() external view returns (address);

    function createLiquidVestingToken(
        string[] memory name,
        string[] memory symbol,
        address redeemToken,
        uint256[] memory activationTimestamp,
        uint256[] memory redeemTimestamp,
        ILiquidVestingToken.AddType addRecipientsType
    ) external;
}


pragma solidity =0.7.6;

contract LiquidVestingTokenFactory is Ownable, ILiquidVestingTokenFactory {
    uint256 public constant MIN_FEE = 0;
    uint256 public constant MAX_FEE = 5000;

    address private tokenImplementation;
    address public override merkleRootSigner;
    address public override feeCollector;
    uint256 public override fee;

    event VestingTokenCreated(
        address indexed redeemToken,
        address vestingToken
    );

    mapping(address => address[]) public vestingTokensByOriginalToken;

    constructor(
        address _tokenImplementation,
        address _merkleRootSigner,
        address _feeCollector,
        uint256 _fee
    ) {
        require(
            Address.isContract(_tokenImplementation),
            "Implementation is not a contract"
        );
        require(
            _merkleRootSigner != address(0),
            "Merkle root signer cannot be zero address"
        );
        require(
            _feeCollector != address(0),
            "Fee collector cannot be zero address"
        );
        require(_fee >= MIN_FEE && _fee <= MAX_FEE, "Fee goes beyond rank");

        merkleRootSigner = _merkleRootSigner;
        feeCollector = _feeCollector;
        fee = _fee;
        tokenImplementation = _tokenImplementation;
    }

    function setMerkleRootSigner(address _newMerkleRootSigner)
        external
        override
        onlyOwner
    {
        require(
            _newMerkleRootSigner != address(0),
            "Merkle root signer cannot be zero address"
        );

        merkleRootSigner = _newMerkleRootSigner;
    }

    function setFeeCollector(address _newFeeCollector)
        external
        override
        onlyOwner
    {
        require(
            _newFeeCollector != address(0),
            "Fee collector cannot be zero address"
        );

        feeCollector = _newFeeCollector;
    }

    function setFee(uint256 _fee) external override {
        require(_msgSender() == feeCollector, "Caller is not fee collector");
        require(_fee >= MIN_FEE && _fee <= MAX_FEE, "Fee goes beyond rank");

        fee = _fee;
    }

    function implementation() external view override returns (address) {
        return tokenImplementation;
    }

    function getMinFee() external pure override returns (uint256) {
        return MIN_FEE;
    }

    function getMaxFee() external pure override returns (uint256) {
        return MAX_FEE;
    }

    function createLiquidVestingToken(
        string[] memory name,
        string[] memory symbol,
        address redeemToken,
        uint256[] memory activationTimestamp,
        uint256[] memory redeemTimestamp,
        ILiquidVestingToken.AddType addRecipientsType
    ) public override {
        require(
            redeemToken != address(0),
            "Company token cannot be zero address"
        );
        require(
            name.length == symbol.length &&
                name.length == activationTimestamp.length &&
                name.length == redeemTimestamp.length,
            "Arrays length should be same"
        );

        uint8 decimals = ERC20(redeemToken).decimals();
        for (uint256 i = 0; i < name.length; i++) {
            require(
                activationTimestamp[i] <= redeemTimestamp[i],
                "activationTimestamp cannot be more than redeemTimestamp"
            );

            BeaconProxy token = new BeaconProxy(address(this), "");
            ILiquidVestingToken(address(token)).initialize(
                name[i],
                symbol[i],
                decimals,
                _msgSender(),
                address(this),
                redeemToken,
                activationTimestamp[i],
                redeemTimestamp[i],
                addRecipientsType
            );

            vestingTokensByOriginalToken[redeemToken].push(address(token));
            emit VestingTokenCreated(redeemToken, address(token));
        }
    }
}