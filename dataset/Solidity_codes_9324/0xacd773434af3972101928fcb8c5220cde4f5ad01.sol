
pragma solidity 0.6.7;

contract GebAuth {

    mapping (address => uint) public authorizedAccounts;
    function addAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "GebAuth/account-not-authorized");
        _;
    }

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);

    constructor () public {
        authorizedAccounts[msg.sender] = 1;
        emit AddAuthorization(msg.sender);
    }
}

abstract contract DSDelegateTokenLike {
    function transfer(address, uint256) external virtual returns (bool);
    function delegate(address) external virtual;
}

contract GebMinimalLocker is GebAuth {

    uint256 public unlockTimestamp;

    constructor(
        uint256 _unlockTimestamp
    ) public {
        require(_unlockTimestamp > now, "GebMinimalLocker/invalid-unlock-timestamp");
        unlockTimestamp = _unlockTimestamp;
    }

    function getTokens(address _token, address _to, uint256 _amount) external isAuthorized {

        require(now >= unlockTimestamp, "GebMinimalLocker/too-early");
        require(DSDelegateTokenLike(_token).transfer(_to, _amount), "GebMinimalLocker/token-transfer-failed");
    }

    function delegate(address _token, address _delegatee) external isAuthorized {

        DSDelegateTokenLike(_token).delegate(_delegatee);
    }
}