
pragma solidity 0.4.26;

contract IOwned {

    function owner() public view returns (address) {this;}


    function transferOwnership(address _newOwner) public;

    function acceptOwnership() public;

}

contract IERC20Token {

    function name() public view returns (string) {this;}

    function symbol() public view returns (string) {this;}

    function decimals() public view returns (uint8) {this;}

    function totalSupply() public view returns (uint256) {this;}

    function balanceOf(address _owner) public view returns (uint256) {_owner; this;}

    function allowance(address _owner, address _spender) public view returns (uint256) {_owner; _spender; this;}


    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

}

contract INonStandardERC20 {

    function name() public view returns (string) {this;}

    function symbol() public view returns (string) {this;}

    function decimals() public view returns (uint8) {this;}

    function totalSupply() public view returns (uint256) {this;}

    function balanceOf(address _owner) public view returns (uint256) {_owner; this;}

    function allowance(address _owner, address _spender) public view returns (uint256) {_owner; _spender; this;}


    function transfer(address _to, uint256 _value) public;

    function transferFrom(address _from, address _to, uint256 _value) public;

    function approve(address _spender, uint256 _value) public;

}

contract ISmartToken is IOwned, IERC20Token {

    function disableTransfers(bool _disable) public;

    function issue(address _to, uint256 _amount) public;

    function destroy(address _from, uint256 _amount) public;

}

contract ITokenHolder is IOwned {

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;

}

contract Utils {

    constructor() public {
    }

    modifier greaterThanZero(uint256 _amount) {

        require(_amount > 0);
        _;
    }

    modifier validAddress(address _address) {

        require(_address != address(0));
        _;
    }

    modifier notThis(address _address) {

        require(_address != address(this));
        _;
    }

}

contract Owned is IOwned {

    address public owner;
    address public newOwner;

    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier ownerOnly {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public ownerOnly {

        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract TokenHolder is ITokenHolder, Owned, Utils {

    constructor() public {
    }

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_to)
        notThis(_to)
    {

        INonStandardERC20(_token).transfer(_to, _amount);
    }
}

interface IConverterWrapper {

    function token() external view returns (IERC20Token);

    function reserveTokens(uint256 _index) external view returns (IERC20Token);

    function getReserveBalance(IERC20Token _reserveToken) external view returns (uint256);

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) external;

    function disableConversions(bool _disable) external;

    function transferOwnership(address _newOwner) external;

    function acceptOwnership() external;

    function acceptTokenOwnership() external;

}

contract FixedSupplyUpgrader is TokenHolder {

    constructor() TokenHolder() public {
    }

    function execute(IConverterWrapper _oldConverter, IConverterWrapper _newConverter, address _bntWallet, address _communityWallet) external
        ownerOnly
        validAddress(_oldConverter)
        validAddress(_newConverter)
        validAddress(_bntWallet)
        validAddress(_communityWallet)
    {

        IERC20Token bntToken = _oldConverter.token();
        IERC20Token ethToken = _oldConverter.reserveTokens(0);
        ISmartToken relayToken = ISmartToken(_newConverter.token());
        relayToken.acceptOwnership();
        _oldConverter.acceptOwnership();
        _newConverter.acceptOwnership();
        _oldConverter.disableConversions(true);
        uint256 bntAmount = bntToken.totalSupply() / 10;
        uint256 ethAmount = _oldConverter.getReserveBalance(ethToken);
        _oldConverter.withdrawTokens(ethToken, _newConverter, ethAmount);
        require(bntToken.transferFrom(_bntWallet, _newConverter, bntAmount));
        relayToken.issue(_bntWallet, bntAmount);
        relayToken.issue(_communityWallet, bntAmount);
        relayToken.transferOwnership(_newConverter);
        _newConverter.acceptTokenOwnership();
        _newConverter.transferOwnership(owner);
        _oldConverter.transferOwnership(owner);
    }
}