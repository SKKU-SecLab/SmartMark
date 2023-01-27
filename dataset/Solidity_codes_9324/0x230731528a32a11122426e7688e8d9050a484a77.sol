
pragma solidity ^0.5.11;
interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external;


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external;


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


interface IFactory {

    function deposit() external payable;

}

contract ColdWallet {

    address public factory;

    constructor(address _factory) public {
        factory = _factory;
    }

    function onlyFactory() internal view {

        require(msg.sender == factory, "sender is not factory");
    }

    function transfer(address payable _to, uint256 amount) public {

        onlyFactory();
        if (address(_to) == address(factory)) {
            IFactory(factory).deposit.value(amount)();
        } else {
            _to.transfer(amount);
        }
    }

    function transferToken(
        address _to,
        uint256 amount,
        address token
    ) public {

        onlyFactory();
        IERC20(token).transfer(_to, amount);
    }

    function setFactory(address _factory) external {

        onlyFactory();
        factory = _factory;
    }

    function() external payable {}
}