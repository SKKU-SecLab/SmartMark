


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}




interface IToken {

    function mint(address to, uint256 amount) external;


    function updateAdmin(address newAdmin) external;

}




contract Context {

    constructor() internal {}


    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





contract BridgeBase is Context {

    address public admin;
    IToken public token;
    mapping(uint256 => bool) public processedNonces;

    enum Step {Burn, Mint}
    event CrossTransfer(
        address from,
        address to,
        uint256 amount,
        uint256 date,
        uint256 nonce,
        Step indexed step
    );

    constructor(address _token) public {
        admin = _msgSender();
        token = IToken(_token);
    }

    modifier onlyAdmin() {

        require(
            _msgSender() == admin,
            'Only admin is allowed to execute this operation.'
        );
        _;
    }

    function updateAdmin(address newAdmin) external onlyAdmin {

        admin = newAdmin;
    }

    function updateTokenAdmin(address newAdmin) external onlyAdmin {

        token.updateAdmin(newAdmin);
    }

    function isProcessed(uint256 _nonce) external view returns (bool) {

        return processedNonces[_nonce];
    }

    function mint(
        address to,
        uint256 amount,
        uint256 otherChainNonce
    ) external onlyAdmin {

        require(
            processedNonces[otherChainNonce] == false,
            'transfer already processed'
        );
        processedNonces[otherChainNonce] = true;
        token.mint(to, amount);
        emit CrossTransfer(
            _msgSender(),
            to,
            amount,
            block.timestamp,
            otherChainNonce,
            Step.Mint
        );
    }
}



pragma solidity ^0.5.0;


contract BridgeEth is BridgeBase {

    constructor(address token) public BridgeBase(token) {}
}