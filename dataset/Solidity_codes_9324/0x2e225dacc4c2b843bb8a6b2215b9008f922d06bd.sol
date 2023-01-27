
pragma solidity >=0.8.0 <0.9.0;

interface IERC20 {


    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transfer(address to, uint256 amount) external returns (bool);


    function transferFrom(address from, address to, uint256 amount) external returns (bool);


}

pragma solidity >=0.8.0 <0.9.0;


contract DeriBurnerETH {


    address public constant deri = 0xA487bF43cF3b10dffc97A9A744cbB7036965d3b9;
    address public constant deadlock = 0x000000000000000000000000000000000000dEaD;
    address public constant wormholeETH = 0x6874640cC849153Cb3402D193C33c416972159Ce;

    function burnDeri() public {

        uint256 balance = IERC20(deri).balanceOf(address(this));
        if (balance != 0) {
            IERC20(deri).transfer(deadlock, balance);
        }
    }

    function claimAndBurnDeri(
        uint256 amount,
        uint256 fromChainId,
        address fromWormhole,
        uint256 fromNonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {

        IWormhole(wormholeETH).claim(amount, fromChainId, fromWormhole, fromNonce, v, r, s);
        burnDeri();
    }

}

interface IWormhole {

    function claim(uint256 amount, uint256 fromChainId, address fromWormhole, uint256 fromNonce, uint8 v, bytes32 r, bytes32 s) external;

}
