
pragma solidity >=0.4.22 <0.6.0;
interface VIP180 {

    function decimals() external view returns(uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _tokenOwner) external view returns (uint256);

    function transfer(address _to, uint _tokens) external returns (bool);

    function transferFrom(address _from, address _to, uint _tokens) external returns (bool);

    function approve(address _spender, uint _tokens) external returns (bool);

    function allowance(address _tokenOwner, address _spender) external view returns (uint256);


    event Transfer(address indexed _from, address indexed _to, uint _tokens);
    event Approval(address indexed _tokenOwner, address indexed _spender, uint _tokens);
}

contract LockedTokenManager {

    event Lock (address indexed _tokenOwner, address indexed _tokenAddress, uint _tokens);

    event Unlock (address indexed _tokenOwner, address indexed _tokenAddress, uint _tokens);

    uint constant FIRST_MONTH_TIMESTAMP = 1554076800;
    uint constant MAXIMUM_LOCK_MONTHS = 240;
    uint public currentMonth;
    mapping (address => mapping(address => mapping(uint => uint))) tokensLockedUntilMonth;
    
    modifier notZero(uint _param) {

        require (_param != 0, "Parameter cannot be zero");
        _;
    }

    function lock(address _tokenAddress, uint _tokens, uint _numberOfMonths) 
        public 
        notZero(_tokens)
        returns(bool)
    {

        require (
            _numberOfMonths > 0 && _numberOfMonths <= MAXIMUM_LOCK_MONTHS,
            "Invalid number of months"
        );

        VIP180 tokenContract = VIP180(_tokenAddress);
        tokenContract.transferFrom(msg.sender, address(this), _tokens);
        
        tokensLockedUntilMonth[msg.sender][_tokenAddress][currentMonth + _numberOfMonths] += _tokens;
        emit Lock(msg.sender, _tokenAddress, _tokens);

        return true;
    }
    
    function lockFrom(
        address _tokenHolder, 
        address _tokenAddress, 
        uint _tokens, 
        uint _numberOfMonths
    ) public notZero(_tokens) returns(bool) {

        require (
            _numberOfMonths > 0 && _numberOfMonths <= MAXIMUM_LOCK_MONTHS,
            "Invalid number of months"
        );

        VIP180 tokenContract = VIP180(_tokenAddress);
        tokenContract.transferFrom(_tokenHolder, address(this), _tokens);
        
        tokensLockedUntilMonth[_tokenHolder][_tokenAddress][currentMonth + _numberOfMonths] += _tokens;
        emit Lock(_tokenHolder, _tokenAddress, _tokens);

        return true;
    }

    function transferAndLock(
        address _to,
        address _tokenAddress,
        uint _tokens,
        uint _numberOfMonths
    ) external returns (bool) {

        require (
            _numberOfMonths > 0 && _numberOfMonths <= MAXIMUM_LOCK_MONTHS,
            "Invalid number of months"
        );

        VIP180 tokenContract = VIP180(_tokenAddress);
        tokenContract.transferFrom(msg.sender, address(this), _tokens);
        
        tokensLockedUntilMonth[_to][_tokenAddress][currentMonth + _numberOfMonths] += _tokens;
        emit Lock(_to, _tokenAddress, _tokens);

        return true;
    }
    
    function transferFromAndLock(
        address _from,
        address _to,
        address _tokenAddress,
        uint _tokens,
        uint _numberOfMonths
    ) external returns (bool) {

        require (
            _numberOfMonths > 0 && _numberOfMonths <= MAXIMUM_LOCK_MONTHS,
            "Invalid number of months"
        );

        VIP180 tokenContract = VIP180(_tokenAddress);
        tokenContract.transferFrom(_from, address(this), _tokens);
        
        tokensLockedUntilMonth[_to][_tokenAddress][currentMonth + _numberOfMonths] += _tokens;
        emit Lock(_to, _tokenAddress, _tokens);

        return true;
    }

    function unlockAll(address _tokenOwner, address _tokenAddress) external {

        address addressToUnlock = _tokenOwner;
        if (addressToUnlock == address(0)) {
            addressToUnlock = msg.sender;
        }
        VIP180 tokenContract = VIP180(_tokenAddress);
        if (msg.sender != addressToUnlock) {
            require (
                tokenContract.allowance(addressToUnlock, msg.sender) > 0,
                "Not authorized to unlock for this address"
            );
        }

        uint tokensToUnlock;
        for (uint i = 1; i <= currentMonth; ++i) {
            tokensToUnlock += tokensLockedUntilMonth[addressToUnlock][_tokenAddress][i];
            tokensLockedUntilMonth[addressToUnlock][_tokenAddress][i] = 0;
        }
        tokenContract.transfer(addressToUnlock, tokensToUnlock);
        emit Unlock (addressToUnlock, _tokenAddress, tokensToUnlock);
    }

    function unlockByMonth(
        address _tokenOwner, 
        address _tokenAddress, 
        uint _month
    ) external {

        address addressToUnlock = _tokenOwner;
        if (addressToUnlock == address(0)) {
            addressToUnlock = msg.sender;
        }
        VIP180 tokenContract = VIP180(_tokenAddress);
        if (msg.sender != addressToUnlock) {
            require (
                tokenContract.allowance(addressToUnlock, msg.sender) > 0,
                "Not authorized to unlock for this address"
            );
        }
        require (
            currentMonth >= _month,
            "Tokens from this month cannot be unlocked yet"
        );
        uint tokensToUnlock = tokensLockedUntilMonth[addressToUnlock][_tokenAddress][_month];
        tokensLockedUntilMonth[addressToUnlock][_tokenAddress][_month] = 0;
        tokenContract.transfer(addressToUnlock, tokensToUnlock);
        emit Unlock(addressToUnlock, _tokenAddress, tokensToUnlock);
    }

    function updateMonthsSinceRelease() external {

        uint secondsSinceRelease = block.timestamp - FIRST_MONTH_TIMESTAMP;
        require (
            currentMonth < secondsSinceRelease / (30 * 1 days + 10 * 1 hours + 30 * 1 minutes),
            "Cannot update month yet"
        );
        ++currentMonth;
    }

    function viewTotalLockedTokens(
        address _tokenOwner,
        address _tokenAddress
    ) public view returns (uint lockedTokens) {

        for (uint i = 1; i < currentMonth + MAXIMUM_LOCK_MONTHS; ++i) {
            lockedTokens += tokensLockedUntilMonth[_tokenOwner][_tokenAddress][i];
        }
    }

    function viewLockedTokensByMonth(
        address _tokenOwner,
        address _tokenAddress,
        uint _month
    ) external view returns (uint) {

        return tokensLockedUntilMonth[_tokenOwner][_tokenAddress][_month];
    }
}