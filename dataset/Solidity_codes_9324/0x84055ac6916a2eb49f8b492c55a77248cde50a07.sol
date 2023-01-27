
pragma solidity ^0.5.0;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

}

interface UniswapFactory {

    function getExchange(address token) external view returns (address exchange);

}

interface UniswapPool {

    function tokenAddress() external view returns (address token);

    function factoryAddress() external view returns (address factory);

    function addLiquidity(uint256 minLiquidity, uint256 maxTokens, uint256 deadline) external payable returns (uint256);

    function removeLiquidity(
        uint256 amount,
        uint256 minEth,
        uint256 minTokens,
        uint256 deadline
        ) external returns (uint256, uint256);


    function totalSupply() external view returns (uint);

}


contract Helper {


    function getAddressUniFactory() public pure returns (address factory) {

        factory = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    }

    function getAddressPool(address _token) public view returns (address) {

        return UniswapFactory(getAddressUniFactory()).getExchange(_token);
    }

    function getAddressAdmin() public pure returns (address admin) {

        admin = 0x7284a8451d9a0e7Dc62B3a71C0593eA2eC5c5638;
    }

    function getBal(address src, address _owner) internal view returns (uint, uint) {

        uint tknBal = IERC20(src).balanceOf(address(_owner));
        return (address(_owner).balance, tknBal);
    }

    function setApproval(address token, uint srcAmt, address to) internal {

        IERC20 erc20Contract = IERC20(token);
        uint tokenAllowance = erc20Contract.allowance(address(this), to);
        if (srcAmt > tokenAllowance) {
            erc20Contract.approve(to, 2**255);
        }
    }
    
}


contract Pool is Helper {


    event LogAddLiquidity(
        address token,
        uint tokenAmt,
        uint ethAmt,
        uint poolTokenMinted,
        address beneficiary
    );

    event LogRemoveLiquidity(
        address token,
        uint tokenReturned,
        uint ethReturned,
        uint poolTokenBurned,
        address beneficiary
    );

    event LogShutPool(
        address token,
        uint tokenReturned,
        uint ethReturned,
        uint poolTokenBurned,
        address beneficiary
    );

    function poolDetails(
        address token
    ) public view returns (
        address poolAddress,
        uint totalSupply,
        uint ethReserve,
        uint tokenReserve
    )
    {

        poolAddress = getAddressPool(token);
        totalSupply = IERC20(poolAddress).totalSupply();
        (ethReserve, tokenReserve) = getBal(token, poolAddress);
    }

    function addLiquidity(address token, uint maxDepositedTokens) public payable returns (uint256 tokensMinted) {

        address poolAddr = getAddressPool(token);
        (uint ethReserve, uint tokenReserve) = getBal(token, poolAddr);
        uint tokenToDeposit = msg.value * tokenReserve / ethReserve + 1;
        require(tokenToDeposit < maxDepositedTokens, "Token to deposit is greater than Max token to Deposit");
        IERC20(token).transferFrom(msg.sender, address(this), tokenToDeposit);
        setApproval(token, tokenToDeposit, poolAddr);
        tokensMinted = UniswapPool(poolAddr).addLiquidity.value(msg.value)(
            uint(1),
            tokenToDeposit,
            uint(1899063809) // 6th March 2030 GMT // no logic
        );
        emit LogAddLiquidity(
            token,
            tokenToDeposit,
            msg.value,
            tokensMinted,
            msg.sender
        );
    }

    function removeLiquidity(
        address token,
        uint amount,
        uint minEth,
        uint minTokens
    ) public returns (uint ethReturned, uint tokenReturned)
    {

        address poolAddr = getAddressPool(token);

        setApproval(poolAddr, amount, poolAddr);
        (ethReturned, tokenReturned) = UniswapPool(poolAddr).removeLiquidity(
            amount,
            minEth,
            minTokens,
            uint(1899063809) // 6th March 2030 GMT // no logic
        );
        address(msg.sender).transfer(ethReturned);
        IERC20(token).transfer(msg.sender, tokenReturned);
        emit LogRemoveLiquidity(
            token,
            tokenReturned,
            ethReturned,
            amount,
            msg.sender
        );
    }

    function shut(address token) public returns (uint ethReturned, uint tokenReturned) {

        address poolAddr = getAddressPool(token);
        uint userPoolBal = IERC20(poolAddr).balanceOf(address(this));

        setApproval(poolAddr, userPoolBal, poolAddr);
        (ethReturned, tokenReturned) = UniswapPool(poolAddr).removeLiquidity(
            userPoolBal,
            uint(1),
            uint(1),
            uint(1899063809) // 6th March 2030 GMT // no logic
        );
        address(msg.sender).transfer(ethReturned);
        IERC20(token).transfer(msg.sender, tokenReturned);
        emit LogShutPool(
            token,
            tokenReturned,
            ethReturned,
            userPoolBal,
            msg.sender
        );
    }

}


contract InstaUniswapPool is Pool {


    uint public version;
    
    constructor(uint _version) public {
        version = _version;
    }

    function() external payable {}

}