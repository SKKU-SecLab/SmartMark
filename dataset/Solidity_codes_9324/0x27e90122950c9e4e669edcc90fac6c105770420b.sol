

pragma solidity >=0.4.0;

interface IWETH9 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function balanceOf(address) external view returns (uint);


    function allowance(address, address) external view returns (uint);


    receive() external payable;

    function deposit() external payable;


    function withdraw(uint wad) external;


    function totalSupply() external view returns (uint);


    function approve(address guy, uint wad) external returns (bool);


    function transfer(address dst, uint wad) external returns (bool);


    function transferFrom(address src, address dst, uint wad)
    external
    returns (bool);

}


pragma solidity >=0.4.0;

interface IAdvancedWETH {

    function weth() external view returns (address payable);


    function depositAndTransferFromThenCall(uint amount, address to, bytes calldata data) external payable;


    function withdrawTo(address payable to) external;

}


pragma solidity =0.6.7;



contract AdvancedWETH is IAdvancedWETH {

    address payable public override immutable weth;

    constructor(address payable weth_) public {
        weth = weth_;
    }

    function depositAndTransferFromThenCall(uint amount, address to, bytes calldata data) external override payable {

        if (msg.value > 0) {
            IWETH9(weth).deposit{value: msg.value}();
        }
        if (amount > 0) {
            IWETH9(weth).transferFrom(msg.sender, address(this), amount);
        }
        uint total = msg.value + amount;
        require(total >= msg.value, 'OVERFLOW'); // nobody should be this rich.
        require(total > 0, 'ZERO_INPUTS');
        IWETH9(weth).approve(to, total);
        (bool success,) = to.call(data);
        require(success, 'TO_CALL_FAILED');
        withdrawTo(msg.sender);
    }

    receive() payable external { require(msg.sender == weth, 'WETH_ONLY'); }

    function withdrawTo(address payable to) public override {

        uint wethBalance = IWETH9(weth).balanceOf(address(this));
        if (wethBalance > 0) {
            IWETH9(weth).withdraw(wethBalance);
            (bool success,) = to.call{value: wethBalance}('');
            require(success, 'WITHDRAW_TO_CALL_FAILED');
        }
    }
}