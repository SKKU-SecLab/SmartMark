

pragma solidity 0.8.4;

interface IERC20{} interface IBentoBoxBasic {

    function deposit( 
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external payable returns (uint256 amountOut, uint256 shareOut);


    function withdraw(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);

}

interface ISushiBar { 

    function balanceOf(address account) external view returns (uint256);

    function enter(uint256 amount) external;

    function leave(uint256 share) external;

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

contract Meowshi {

    IBentoBoxBasic constant bento = IBentoBoxBasic(0xF5BCE5077908a1b7370B9ae04AdC565EBd643966); // BENTO vault contract (multinet)
    ISushiBar constant sushiToken = ISushiBar(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2); // SUSHI token contract (mainnet)
    address constant sushiBar = 0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272; // xSUSHI token contract for staking SUSHI (mainnet)
    string constant public name = "Meowshi";
    string constant public symbol = "MEOW";
    uint8 constant public decimals = 18;
    uint256 constant multiplier = 100_000; // 1 xSUSHI BENTO share = 100,000 MEOW
    uint256 public totalSupply;
    
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public nonces;
    mapping(address => address) public delegates;
    mapping(address => mapping(uint256 => Checkpoint)) public checkpoints;
    mapping(address => uint256) public numCheckpoints;
    bytes32 constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    bytes32 constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
    bytes32 constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);
    
    struct Checkpoint {
        uint256 fromBlock;
        uint256 votes;
    }
    
    constructor() {
        sushiToken.approve(sushiBar, type(uint256).max); // max {approve} xSUSHI to draw SUSHI from this contract
        ISushiBar(sushiBar).approve(address(bento), type(uint256).max); // max {approve} BENTO to draw xSUSHI from this contract
    }
    
    function multicall(bytes[] calldata data) external returns (bytes[] memory results) {

        results = new bytes[](data.length);
        unchecked {for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            if (!success) {
                if (result.length < 68) revert();
                assembly {result := add(result, 0x04)}
                revert(abi.decode(result, (string)));
            }
            results[i] = result;}}
    }
    
    function meow(address to, uint256 amount) external returns (uint256 shares) {

        ISushiBar(sushiBar).transferFrom(msg.sender, address(bento), amount); // forward to BENTO for skim
        (, shares) = bento.deposit(IERC20(sushiBar), address(bento), address(this), amount, 0);
        meowMint(to, shares * multiplier);
    }

    function unmeow(address to, uint256 amount) external returns (uint256 amountOut) {

        meowBurn(amount);
        unchecked {(amountOut, ) = bento.withdraw(IERC20(sushiBar), address(this), to, 0, amount / multiplier);}
    }
    
    function meowSushi(address to, uint256 amount) external returns (uint256 shares) {

        sushiToken.transferFrom(msg.sender, address(this), amount);
        ISushiBar(sushiBar).enter(amount);
        (, shares) = bento.deposit(IERC20(sushiBar), address(this), address(this), balanceOfOptimized(sushiBar), 0);
        meowMint(to, shares * multiplier);
    }

    function unmeowSushi(address to, uint256 amount) external returns (uint256 amountOut) {

        meowBurn(amount);
        unchecked {(amountOut, ) = bento.withdraw(IERC20(sushiBar), address(this), address(this), 0, amount / multiplier);}
        ISushiBar(sushiBar).leave(amountOut);
        sushiToken.transfer(to, balanceOfOptimized(address(sushiToken))); 
    }

    function meowMint(address to, uint256 amount) private {

        balanceOf[to] += amount;
        totalSupply += amount;
        _moveDelegates(address(0), delegates[to], amount);
        emit Transfer(address(0), to, amount);
    }
    
    function meowBurn(uint256 amount) private {

        balanceOf[msg.sender] -= amount;
        unchecked {totalSupply -= amount;}
        _moveDelegates(delegates[msg.sender], address(0), amount);
        emit Transfer(msg.sender, address(0), amount);
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {

        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function permit(address owner, address spender, uint256 amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        unchecked {bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s); 
        require(signatory != address(0), 'Meowshi::permit: invalid signature');
        require(signatory == owner, 'Meowshi::permit: unauthorized');}
        require(block.timestamp <= deadline, 'Meowshi::permit: signature expired');
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {

        balanceOf[msg.sender] -= amount; 
        unchecked {balanceOf[to] += amount;}
        _moveDelegates(delegates[msg.sender], delegates[to], amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {

        if (allowance[from][msg.sender] != type(uint256).max) {allowance[from][msg.sender] -= amount;}
        balanceOf[from] -= amount;
        unchecked {balanceOf[to] += amount;}
        _moveDelegates(delegates[from], delegates[to], amount);
        emit Transfer(from, to, amount);
        return true;
    }
    
    function delegate(address delegatee) external {

        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) external {

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), 'Meowshi::delegateBySig: invalid signature');
        unchecked {require(nonce == nonces[signatory]++, 'Meowshi::delegateBySig: invalid nonce');}
        require(block.timestamp <= expiry, 'Meowshi::delegateBySig: signature expired');
        return _delegate(signatory, delegatee);
    }
    
    function _delegate(address delegator, address delegatee) private {

        address currentDelegate = delegates[delegator]; 
        delegates[delegator] = delegatee;
        emit DelegateChanged(delegator, currentDelegate, delegatee);
        _moveDelegates(currentDelegate, delegatee, balanceOf[delegator]);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) private {

        if (srcRep != dstRep && amount != 0) {
            unchecked {if (srcRep != address(0)) {
                uint256 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum != 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld - amount;
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }
            if (dstRep != address(0)) {
                uint256 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum != 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld + amount;
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }}
        }
    }
    
    function _writeCheckpoint(address delegatee, uint256 nCheckpoints, uint256 oldVotes, uint256 newVotes) private {

        unchecked {if (nCheckpoints != 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == block.number) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(block.number, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;}}
        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }
    
    function balanceOfOptimized(address token) private view returns (uint256 amount) {

        (bool success, bytes memory data) =
            token.staticcall(abi.encodeWithSelector(ISushiBar.balanceOf.selector, address(this)));
        require(success && data.length >= 32);
        amount = abi.decode(data, (uint256));
    }
    
    function getChainId() private view returns (uint256 Id) {

        uint256 chainId;
        assembly {chainId := chainid()}
        Id = chainId;
    }

    function getCurrentVotes(address account) external view returns (uint256 votes) {

        unchecked {uint256 nCheckpoints = numCheckpoints[account];
        votes = nCheckpoints != 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;}
    }

    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256 votes) {

        require(blockNumber < block.number, 'Meowshi::getPriorVotes: not yet determined');
        uint256 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {votes = 0;}
        unchecked {if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {votes = checkpoints[account][nCheckpoints - 1].votes;}
        if (checkpoints[account][0].fromBlock > blockNumber) {votes = 0;}
        uint256 lower;
        uint256 upper = nCheckpoints - 1;
        while (upper != lower) {
            uint256 center = upper - (upper - lower) / 2;
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                votes = cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {upper = center - 1;}}
        votes = checkpoints[account][lower].votes;}
    }
}