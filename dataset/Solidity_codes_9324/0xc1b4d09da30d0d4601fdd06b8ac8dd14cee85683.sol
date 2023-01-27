



pragma solidity 0.6.12;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract MultiTransfer {

    uint256 private constant S_NOT_ENTERED = 1;
    uint256 private constant S_ENTERED = 2;
    uint256 private _status = S_NOT_ENTERED;

    function multiTransferERC20(address token, address[] calldata recipients, uint256[] calldata amounts) external {

        uint256 count = recipients.length;
        require(
               _status == S_NOT_ENTERED
            && count > 0
        , "Not authorized.");
        _status = S_ENTERED;

        bool failed;
        address recipient;
        uint256 amount;
        for (uint256 i; i < count; i ++) {
            recipient = recipients[i];
            amount = amounts[i];

            if (recipient == address(0) || recipient == msg.sender || recipient == address(this) || amount == 0) {
                continue;
            }

            IERC20(token).transferFrom(msg.sender, recipient, amount);
        }

        require(!failed, "Transfer failed!");
        _status = S_NOT_ENTERED;
    }
}