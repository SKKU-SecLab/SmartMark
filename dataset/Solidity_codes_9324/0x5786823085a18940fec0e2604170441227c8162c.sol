
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity ^0.8.4;


contract LPClaimer{


    uint256 public constant MAX_SUPPLY = uint248(1111111 ether);
    mapping(address => bool) private _minted;

    IERC20 private TWO; //mainnet 0xB711Bac062F74c5C6d4a2cb55639a270881a12EE

    constructor(address _signer, address _two) {
        cSigner = _signer;
        TWO = IERC20(_two);
    }

    address public immutable cSigner;

     function minted(address account) public view returns (bool) {

        return _minted[account];
    }

    function claim(uint248 amount, uint8 v, bytes32 r, bytes32 s) external {

        require(minted(msg.sender) == false, "LP Reward: Already Claimed");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(
                    abi.encode(
                        amount,msg.sender
                    )
                )
            )
        );
        require(ecrecover(digest, v, r, s) == cSigner, "LP Reward: Invalid signer");
        _minted[msg.sender] = true;
        TWO.transfer(msg.sender, amount);
    }
}