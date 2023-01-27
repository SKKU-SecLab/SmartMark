
pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// AGPL-3.0

pragma solidity 0.7.1;

interface IMinter {

    event Minted(address _sender, uint256 _amount);
    event Burned(address _sender, uint256 _amount);

    function mint(uint256 _amount) external;


    function burn(uint256 _amount) external;


    function iQ() external view returns (address);


    function wrappedIQ() external view returns (address);

}// AGPL-3.0

pragma solidity 0.7.1;


interface IIQERC20 {

    function mint(address _addr, uint256 _amount) external;


    function burn(address _addr, uint256 _amount) external;


    function setMinter(IMinter _addr) external;


    function minter() external view returns (address);

}// AGPL-3.0
pragma solidity 0.7.1;


contract TokenMinter is IMinter {

    IIQERC20 private _iQ;
    IERC20 private _wrappedIQ;
    bool internal locked;

    modifier blockReentrancy {

        require(!locked, "Contract is locked");
        locked = true;
        _;
        locked = false;
    }

    constructor(IIQERC20 iQ, IERC20 wrappedIQ) {
        _iQ = iQ;
        _wrappedIQ = wrappedIQ;
    }

    function mint(uint256 _amount) external override blockReentrancy {

        require(_wrappedIQ.transferFrom(msg.sender, address(this), _amount), "Transfer has failed");
        _iQ.mint(msg.sender, _amount);
        emit Minted(msg.sender, _amount);
    }

    function burn(uint256 _amount) external override blockReentrancy {

        _iQ.burn(msg.sender, _amount);
        require(_wrappedIQ.transfer(msg.sender, _amount), "Transfer has failed");
        emit Burned(msg.sender, _amount);
    }

    function transferWrapped(address _addr, uint256 _amount) external {

        require(msg.sender == Ownable(address(_iQ)).owner(), "Only IQ owner can tranfer wrapped tokens");
        require(address(this) != _iQ.minter(), "Minter is still in use");
        require(_wrappedIQ.transfer(_addr, _amount), "Transfer has failed");
    }

    function iQ() external view override returns (address) {

        return address(_iQ);
    }

    function wrappedIQ() external view override returns (address) {

        return address(_wrappedIQ);
    }
}

abstract contract Ownable {
    function owner() public view virtual returns (address);
}