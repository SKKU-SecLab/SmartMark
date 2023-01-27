

pragma solidity >=0.8.0 <0.9.0;

contract LexLocker {

    uint256 lockerCount;
    mapping(uint256 => Locker) public lockers;
    mapping(address => Resolver) public resolvers;
    
    event Deposit(
        bool nft,
        address indexed depositor, 
        address indexed receiver, 
        address resolver,
        address token, 
        uint256 value, 
        uint256 indexed registration,
        string details);
    event Release(uint256 indexed registration);
    event Lock(uint256 indexed registration);
    event Resolve(uint256 indexed registration, uint256 indexed depositorAward, uint256 indexed receiverAward, string details);
    event RegisterResolver(address indexed resolver, bool indexed active, uint256 indexed fee);
    
    struct Locker {  
        bool nft; 
        bool locked;
        address depositor;
        address receiver;
        address resolver;
        address token;
        uint256 value;
    }
    
    struct Resolver {
        bool active;
        uint8 fee;
    }
    
    function deposit(
        address receiver, 
        address resolver, 
        address token, 
        uint256 value, 
        bool nft, 
        string calldata details
    ) external payable returns (uint256 registration) {

        require(resolvers[resolver].active, "resolver not active");
        
        if (msg.value != 0) {
            require(msg.value == value, "wrong msg.value");
            if (token != address(0)) token = address(0);
        } else {
            safeTransferFrom(token, msg.sender, address(this), value);
        }
        
        lockerCount++;
        registration = lockerCount;
        lockers[registration] = Locker(nft, false, msg.sender, receiver, resolver, token, value);
        
        emit Deposit(nft, msg.sender, receiver, resolver, token, value, registration, details);
    }
    
    function release(uint256 registration) external {

        Locker storage locker = lockers[registration]; 
        
        require(msg.sender == locker.depositor, "not depositor");
        require(!locker.locked, "locked");
        
        if (locker.token == address(0)) { /// @dev Release ETH.
            safeTransferETH(locker.receiver, locker.value);
        } else if (!locker.nft) { /// @dev Release ERC-20.
            safeTransfer(locker.token, locker.receiver, locker.value);
        } else { /// @dev Release NFT.
            safeTransferFrom(locker.token, address(this), locker.receiver, locker.value);
        }
        
        delete lockers[registration];
        
        emit Release(registration);
    }
    
    function lock(uint256 registration) external {

        Locker storage locker = lockers[registration];
        
        require(msg.sender == locker.depositor || msg.sender == locker.receiver, "Not locker party");
        
        locker.locked = true;
        
        emit Lock(registration);
    }
    
    function resolve(uint256 registration, uint256 depositorAward, uint256 receiverAward, string calldata details) external {

        Locker storage locker = lockers[registration]; 
        
        require(msg.sender == locker.resolver, "not resolver");
        require(locker.locked, "not locked");
        require(depositorAward + receiverAward == locker.value, "not remainder");
        
        unchecked {
            uint256 resolverFee = locker.value / resolvers[locker.resolver].fee / 2;
            depositorAward -= resolverFee;
            receiverAward -= resolverFee;
        }
        
        if (locker.token == address(0)) { /// @dev Split ETH.
            safeTransferETH(locker.depositor, depositorAward);
            safeTransferETH(locker.receiver, receiverAward);
        } else if (!locker.nft) { /// @dev ...ERC20.
            safeTransfer(locker.token, locker.depositor, depositorAward);
            safeTransfer(locker.token, locker.receiver, receiverAward);
        } else { /// @dev Award NFT.
            if (depositorAward != 0) {
                safeTransferFrom(locker.token, address(this), locker.depositor, locker.value);
            } else {
                safeTransferFrom(locker.token, address(this), locker.receiver, locker.value);
            }
        }
        
        delete lockers[registration];
        
        emit Resolve(registration, depositorAward, receiverAward, details);
    }
    
    function registerResolver(bool active, uint8 fee) external {

        resolvers[msg.sender] = Resolver(active, fee);
        emit RegisterResolver(msg.sender, active, fee);
    }
    
    function safeTransfer(address token, address recipient, uint256 value) private {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, recipient, value)); // @dev transfer(address,uint256).
        require(success && (data.length == 0 || abi.decode(data, (bool))), "transfer failed");
    }

    function safeTransferFrom(address token, address sender, address recipient, uint256 value) private {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, sender, recipient, value)); // @dev transferFrom(address,address,uint256).
        require(success && (data.length == 0 || abi.decode(data, (bool))), "pull transfer failed");
    }
    
    function safeTransferETH(address recipient, uint256 value) private {

        (bool success, ) = recipient.call{value: value}("");
        require(success, "eth transfer failed");
    }
}