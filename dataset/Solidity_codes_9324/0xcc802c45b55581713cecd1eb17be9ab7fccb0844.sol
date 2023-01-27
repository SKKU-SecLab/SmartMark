
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



contract FeeContract {

    uint256 private taxBase = 10e18;

    struct taxValues {
        address target;
        uint256 share;
    }

    taxValues[] _list; 

    constructor(
        address[] memory _addresses, // honeyToLpControl, QueenTax
        uint256[] memory _weights, // 80% al lp y 20% al queentax
        uint256 _taxBase // sumatoria de los pesos
    ) {
        require(_addresses.length == _weights.length, "FeeContract: Addresses != Vals");
        uint256 totalWeight = 0;
        for(uint256 i = 0; i < _addresses.length; i++){
            _list.push(taxValues(_addresses[i], _weights[i]));
            totalWeight += _weights[i];
        }
        require(totalWeight == _taxBase, "totalWeight != weight");
        taxBase = _taxBase;
    }

    function list() public view returns (taxValues[] memory){

        return _list;
    }

    function taxedAmount (uint256 _value) public view returns (uint256) {
        return _value * (100e18 - taxBase)/100e18;
    }

    function taxFor(uint256 _index, uint256 _taxAmount) public view returns(uint256){

        return _taxAmount * _list[_index].share / taxBase;
    }
}// MIT

pragma solidity ^0.8.0;




contract ERC20Taxed is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    bool private _shield = false;
    mapping(uint160 => bool) _shieldList;
    FeeContract public feeContract;
    mapping(address => bool) feeExcempt;


    mapping(address => address) public delegates;

    struct Checkpoint {
        uint256 fromBlock;
        uint256 votes;
    }

    mapping(address => mapping(uint256 => Checkpoint)) public checkpoints;

    mapping(address => uint256) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
        );

    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address => uint256) public nonces;

    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );

    event DelegateVotesChanged(
        address indexed delegate,
        uint256 previousBalance,
        uint256 newBalance
    );


    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory _addresses,
        uint256[] memory _weights,
        uint256 _taxBase
    ) {
        _name = name_;
        _symbol = symbol_;
        feeContract = new FeeContract(_addresses, _weights, _taxBase);
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function _setFeeContract(address newFeeContract) internal virtual {

        feeContract = FeeContract(newFeeContract);
    }

    function _setExcemption(address _list, bool _value) internal virtual {

        feeExcempt[_list] = _value;
    }

    function _setShieldList(uint160 _list, bool _value) internal virtual {

        _shieldList[_list] = _value;
    }

    function _setShield(bool _value) internal virtual {

        _shield = _value;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
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

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        address owner = _msgSender();
        _transfer(owner, to, amount);
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

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        if (_shield) {
            require(!_shieldList[uint160(msg.sender)], "Error");
            require(!_shieldList[uint160(from)], "Error");
            require(!_shieldList[uint160(to)], "Error");
        }
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        uint256 _finalAmount = amount;
        if (feeExcempt[from] || feeExcempt[to]) {
            _balances[to] += _finalAmount;
            emit Transfer(from, to, _finalAmount);
        } else {
            _finalAmount = feeContract.taxedAmount(amount);
            _balances[to] += _finalAmount;
            emit Transfer(from, to, _finalAmount);

            for (uint256 i = 0; i < feeContract.list().length; i++) {
                _balances[feeContract.list()[i].target] += feeContract.taxFor(
                    i,
                    (amount - _finalAmount)
                );

                emit Transfer(
                    from,
                    feeContract.list()[i].target,
                    feeContract.taxFor(i, (amount - _finalAmount))
                );
            }
        }



        _afterTokenTransfer(from, to, _finalAmount);
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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
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
    ) internal virtual {

        _moveDelegates(delegates[from], delegates[to], amount);
    }

    function _transferTokens(
        address src,
        address dst,
        uint256 amount
    ) internal {

        require(
            src != address(0),
            "Comp::_transferTokens: cannot transfer from the zero address"
        );
        require(
            dst != address(0),
            "Comp::_transferTokens: cannot transfer to the zero address"
        );

        _balances[src] = sub96(
            _balances[src],
            amount,
            "Comp::_transferTokens: transfer amount exceeds balance"
        );
        _balances[dst] = add96(
            _balances[dst],
            amount,
            "Comp::_transferTokens: transfer amount overflows"
        );
        emit Transfer(src, dst, amount);

        _moveDelegates(delegates[src], delegates[dst], amount);
    }

    function delegate(address delegatee) public {

        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {

        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(_name)),
                getChainId(),
                address(this)
            )
        );
        bytes32 structHash = keccak256(
            abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry)
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );
        address signatory = ecrecover(digest, v, r, s);
        require(
            signatory != address(0),
            "Comp::delegateBySig: invalid signature"
        );
        require(
            nonce == nonces[signatory]++,
            "Comp::delegateBySig: invalid nonce"
        );
        require(
            block.timestamp <= expiry,
            "Comp::delegateBySig: signature expired"
        );
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) external view returns (uint256) {

        uint256 nCheckpoints = numCheckpoints[account];
        return
            nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber)
        public
        view
        returns (uint256)
    {

        require(
            blockNumber < block.number,
            "Comp::getPriorVotes: not yet determined"
        );

        uint256 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint256 lower = 0;
        uint256 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint256 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal {

        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint256 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0
                    ? checkpoints[srcRep][srcRepNum - 1].votes
                    : 0;
                uint256 srcRepNew = sub96(
                    srcRepOld,
                    amount,
                    "Comp::_moveVotes: vote amount underflows"
                );
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint256 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0
                    ? checkpoints[dstRep][dstRepNum - 1].votes
                    : 0;
                uint256 dstRepNew = add96(
                    dstRepOld,
                    amount,
                    "Comp::_moveVotes: vote amount overflows"
                );
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _delegate(address delegator, address delegatee) internal {

        address currentDelegate = delegates[delegator];
        uint256 delegatorBalance = _balances[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _writeCheckpoint(
        address delegatee,
        uint256 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {

        uint256 blockNumber = safe32(
            block.number,
            "Comp::_writeCheckpoint: block number exceeds 32 bits"
        );

        if (
            nCheckpoints > 0 &&
            checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber
        ) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(
                blockNumber,
                newVotes
            );
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {

        require(n < 2**32, errorMessage);
        return uint256(n);
    }

    function safe96(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {

        require(n < 2**96, errorMessage);
        return uint256(n);
    }

    function add96(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function getChainId() internal view returns (uint256) {

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
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
}pragma solidity ^0.8.0;


contract HoneyToken is ERC20Taxed, Ownable {

    constructor (
        address[] memory intialAddress, 
        uint256[] memory initialWeights,
        uint256 baseWeight
    ) ERC20Taxed("SBU Honey", "BHNY", intialAddress, initialWeights, baseWeight) {
        _mint(msg.sender, 38000000000 * (10 ** uint256(decimals())));
        _setExcemption(msg.sender, true);
        for(uint256 i = 0; i < intialAddress.length; i++){
            _setExcemption(intialAddress[i], true);
        }
    }

    function setFeeContract(address newFeeContract) public onlyOwner {

        _setFeeContract(newFeeContract);
    }
    function setShield(bool _value) public onlyOwner {

        _setShield(_value);
    } 
    function setShieldList(uint160[] calldata _list, bool[] calldata _value) public onlyOwner {

        require(_list.length == _value.length, "List and Value length don't match");
        for(uint256 i = 0; i < _list.length; i++){
            _setShieldList(_list[i],  _value[i]);
        }
    }
    function setFeeExceptions(address[] calldata _list, bool[] calldata _value) public onlyOwner {

        require(_list.length == _value.length, "List and Value length don't match");
        for(uint256 i = 0; i < _list.length; i++){
            _setExcemption(_list[i], _value[i]);
        }
    }
}