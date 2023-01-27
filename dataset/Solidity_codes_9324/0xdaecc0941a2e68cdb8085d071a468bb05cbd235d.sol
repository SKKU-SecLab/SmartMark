

pragma solidity 0.7.6;



interface IERC20 {


    function totalSupply() external view returns (uint);

    function balanceOf(address whom) external view returns (uint);

    function allowance(address src, address dst) external view returns (uint);


    function approve(address dst, uint amt) external returns (bool);

    function transfer(address dst, uint amt) external returns (bool);

    function transferFrom(
        address src, address dst, uint amt
    ) external returns (bool);

}

pragma solidity 0.7.6;

interface IDerivativeSpecification {

    function isDerivativeSpecification() external pure returns (bool);


    function oracleSymbols() external view returns (bytes32[] memory);


    function oracleIteratorSymbols() external view returns (bytes32[] memory);


    function collateralTokenSymbol() external view returns (bytes32);


    function collateralSplitSymbol() external view returns (bytes32);


    function livePeriod() external view returns (uint256);


    function primaryNominalValue() external view returns (uint256);


    function complementNominalValue() external view returns (uint256);


    function authorFee() external view returns (uint256);


    function symbol() external view returns (string memory);


    function name() external view returns (string memory);


    function baseURI() external view returns (string memory);


    function author() external view returns (address);

}

pragma solidity 0.7.6;

interface IVault {

    function initializationTime() external view returns(uint256);

    function liveTime() external view returns(uint256);

    function settleTime() external view returns(uint256);


    function underlyingStarts(uint index) external view returns(int256);

    function underlyingEnds(uint index) external view returns(int256);


    function primaryConversion() external view returns(uint256);

    function complementConversion() external view returns(uint256);


    function derivativeSpecification() external view returns(IDerivativeSpecification);

    function collateralToken() external view returns(IERC20);

    function oracles(uint index) external view returns(address);

    function oracleIterators(uint index) external view returns(address);


    function primaryToken() external view returns(IERC20);

    function complementToken() external view returns(IERC20);


    function mint(uint256 _collateralAmount) external;


    function mintTo(address _recipient, uint256 _collateralAmount) external;


    function refund(uint256 _tokenAmount) external;


    function refundTo(address _recipient, uint256 _tokenAmount) external;


    function redeem(
        uint256 _primaryTokenAmount,
        uint256 _complementTokenAmount,
        uint256[] memory _underlyingEndRoundHints
    ) external;


    function redeemTo(
        address _recipient,
        uint256 _primaryTokenAmount,
        uint256 _complementTokenAmount,
        uint256[] memory _underlyingEndRoundHints
    ) external;

}

pragma solidity 0.7.6;

interface IPool is IERC20 {


    function repricingBlock() external view returns(uint);


    function baseFee() external view returns(uint);

    function feeAmp() external view returns(uint);

    function maxFee() external view returns(uint);


    function pMin() external view returns(uint);

    function qMin() external view returns(uint);

    function exposureLimit() external view returns(uint);

    function volatility() external view returns(uint);


    function derivativeVault() external view returns(IVault);

    function dynamicFee() external view returns(address);

    function repricer() external view returns(address);


    function isFinalized()
    external view
    returns (bool);


    function getNumTokens()
    external view
    returns (uint);


    function getTokens()
    external view
    returns (address[] memory tokens);


    function getLeverage(address token)
    external view
    returns (uint);


    function getBalance(address token)
    external view
    returns (uint);


    function getController()
    external view
    returns (address);


    function setController(address manager)
    external;



    function joinPool(uint poolAmountOut, uint[2] calldata maxAmountsIn)
    external;


    function exitPool(uint poolAmountIn, uint[2] calldata minAmountsOut)
    external;


    function swapExactAmountIn(
        address tokenIn,
        uint tokenAmountIn,
        address tokenOut,
        uint minAmountOut
    )
    external
    returns (uint tokenAmountOut, uint spotPriceAfter);

}

pragma solidity 0.7.6;

interface IERC20Metadata {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


pragma solidity 0.7.6;



contract ProxyActions {


    uint public constant BONE = 10**18;

    struct Vars {
        IERC20 collateralToken;
        IERC20 primaryToken;
        IERC20 complementToken;
        IVault vault;
        IPool pool;
        uint256 primaryTokenBalance;
        uint256 complementTokenBalance;
        uint256 primaryTokenAmount;
        uint256 complementTokenAmount;
        IERC20 derivativeIn;
        IERC20 derivativeOut;
        uint256 tokenDecimals;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function mint(
        address _vault,
        uint256 _collateralAmount
    ) external {


        Vars memory vars;
        vars.vault = IVault(_vault);
        vars.collateralToken = IERC20(vars.vault.collateralToken());

        require(
            vars.collateralToken.transferFrom(msg.sender, address(this), _collateralAmount),
            "COLLATERAL_IN"
        );

        vars.collateralToken.approve(_vault, _collateralAmount);

        vars.vault.mintTo(msg.sender, _collateralAmount);
    }

    function refund(
        address _vault,
        uint256 _tokenAmount
    ) external {


        Vars memory vars;
        vars.vault = IVault(_vault);
        vars.primaryToken = IERC20(vars.vault.primaryToken());
        vars.complementToken = IERC20(vars.vault.complementToken());

        require(
            vars.primaryToken.transferFrom(msg.sender, address(this), _tokenAmount),
            "PRIMARY_IN"
        );

        require(
            vars.complementToken.transferFrom(msg.sender, address(this), _tokenAmount),
            "COLLATERAL_IN"
        );

        vars.primaryToken.approve(_vault, _tokenAmount);
        vars.complementToken.approve(_vault, _tokenAmount);

        vars.vault.refundTo(msg.sender, _tokenAmount);
    }

    function redeem(
        address _vault,
        uint256 _primaryTokenAmount,
        uint256 _complementTokenAmount,
        uint256[] memory _underlyingEndRoundHints
    ) external {


        Vars memory vars;
        vars.vault = IVault(_vault);
        vars.primaryToken = IERC20(vars.vault.primaryToken());
        vars.complementToken = IERC20(vars.vault.complementToken());

        if(_primaryTokenAmount > 0) {
            require(
                vars.primaryToken.transferFrom(msg.sender, address(this), _primaryTokenAmount),
                "PRIMARY_IN"
            );
            vars.primaryToken.approve(_vault, _primaryTokenAmount);
        }

        if(_complementTokenAmount > 0) {
            require(
                vars.complementToken.transferFrom(msg.sender, address(this), _complementTokenAmount),
                "COLLATERAL_IN"
            );
            vars.complementToken.approve(_vault, _complementTokenAmount);
        }

        vars.vault.redeemTo(msg.sender, _primaryTokenAmount, _complementTokenAmount, _underlyingEndRoundHints);
    }

    function withdraw(
        address _token
    ) external {

        require(_token != address(0), "ZERO_ADDRESS");
        IERC20 token = IERC20(_token);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function withdrawAll(
        address[] memory _tokens
    ) external {

        for(uint256 i = 0; i < _tokens.length; i++) {
            this.withdraw(_tokens[i]);
        }
    }

    function joinPool(
        address _pool,
        uint256 _poolAmountOut,
        uint256[2] calldata _maxAmountsIn
    ) external {

        Vars memory vars;
        vars.pool = IPool(_pool);

        vars.vault = IVault(vars.pool.derivativeVault());

        vars.primaryToken = IERC20(vars.vault.primaryToken());
        vars.complementToken = IERC20(vars.vault.complementToken());

        require(
            vars.primaryToken.transferFrom(msg.sender, address(this), _maxAmountsIn[0]),
            "TAKE_PRIMARY"
        );

        require(
            vars.complementToken.transferFrom(msg.sender, address(this), _maxAmountsIn[1]),
            "TAKE_COMPLEMENT"
        );

        vars.primaryToken.approve(_pool, _maxAmountsIn[0]);
        vars.complementToken.approve(_pool, _maxAmountsIn[1]);

        vars.pool.joinPool(_poolAmountOut,_maxAmountsIn);

        if (vars.primaryToken.balanceOf(address(this)) > 0) {
            require(
                vars.primaryToken.transfer(msg.sender,vars.primaryToken.balanceOf(address(this))),
                "GIVE_PRIMARY"
            );
        }

        if (vars.complementToken.balanceOf(address(this)) > 0) {
            require(
                    vars.complementToken.transfer(msg.sender,vars.complementToken.balanceOf(address(this))),
                    "GIVE_COMPLEMENT"
                );
        }

        require (vars.pool.transfer( msg.sender, vars.pool.balanceOf(address(this))), "GIVE_POOL");
    }

    function swap(
        address _pool,
        address _tokenIn,
        uint256 _tokenAmountIn,
        address _tokenOut,
        uint256 _minAmountOut
    ) external {


        Vars memory vars;
        vars.pool = IPool(_pool);

        IERC20 tokenIn = IERC20(_tokenIn);
        IERC20 tokenOut = IERC20(_tokenOut);

        require(
            tokenIn.transferFrom(msg.sender, address(this), _tokenAmountIn),
            "TAKE_IN"
        );

        tokenIn.approve(_pool, _tokenAmountIn);

        vars.pool.swapExactAmountIn(_tokenIn,_tokenAmountIn,_tokenOut,_minAmountOut);

        require(
            tokenOut.transfer(msg.sender, tokenOut.balanceOf(address(this))),
            "GIVE_OUT"
        );
    }

    function exitPool(
        address _pool,
        uint256 _poolAmountIn,
        uint256[2] calldata _minAmountsOut
    ) external {

        Vars memory vars;
        vars.pool = IPool(_pool);

        vars.vault = IVault(vars.pool.derivativeVault());

        vars.primaryToken = IERC20(vars.vault.primaryToken());
        vars.complementToken = IERC20(vars.vault.complementToken());
        vars.collateralToken = IERC20(vars.vault.collateralToken());

        require(
            vars.pool.transferFrom(msg.sender, address(this), _poolAmountIn),
            "TAKE_POOL"
        );

        vars.pool.exitPool(_poolAmountIn, _minAmountsOut);

        require(
            vars.primaryToken.transfer(msg.sender, vars.primaryToken.balanceOf(address(this))),
            "GIVE_PRIMARY"
        );
        require(
            vars.complementToken.transfer(msg.sender, vars.complementToken.balanceOf(address(this))),
            "GIVE_COMPLEMENT"
        );
    }

    function mintAndSwapCollateralToDerivative(
        address _pool,
        uint256 _collateralAmount,
        address _tokenIn, // Unwanted Derivative to be swaped
        uint256 _minAmountOut
    ) external {


        Vars memory vars;
        vars.pool = IPool(_pool);

        vars.vault = IVault(vars.pool.derivativeVault());

        vars.collateralToken = IERC20(vars.vault.collateralToken());

        require(
            vars.collateralToken.transferFrom(msg.sender, address(this), _collateralAmount),
            "TAKE_COLLATERAL"
        );

        (IERC20 tokenOut) = mintAndSwapCollateralToDerivativeInternal(
            _pool,
            _collateralAmount,
            _tokenIn,
            _minAmountOut
        );

        uint256 tokenOutBalance = tokenOut.balanceOf(address(this));

        require(tokenOut.transfer(msg.sender, tokenOutBalance), "GIVE_OUT");
    }

    function mintAndSwapCollateralToDerivativeInternal(
        address _pool,
        uint256 _collateralAmount,
        address _tokenIn, // Unwanted Derivative to be swaped
        uint256 _minAmountOut
    ) internal returns (IERC20 tokenOut) {


        Vars memory vars;
        vars.pool = IPool(_pool);

        vars.vault = IVault(vars.pool.derivativeVault());

        vars.primaryToken = IERC20(vars.vault.primaryToken());
        vars.complementToken = IERC20(vars.vault.complementToken());
        vars.collateralToken = IERC20(vars.vault.collateralToken());

        vars.collateralToken.approve(address(vars.vault), _collateralAmount);

        vars.vault.mint(_collateralAmount);

        address tokenOutAddress =
        _tokenIn == address(vars.primaryToken)
        ? address(vars.complementToken)
        : address(vars.primaryToken);

        tokenOut = IERC20(tokenOutAddress);
        IERC20 tokenIn = IERC20(_tokenIn);

        uint256 tokenInBalance = tokenIn.balanceOf(address(this));

        tokenIn.approve(_pool, tokenInBalance);

        vars.pool.swapExactAmountIn(
            _tokenIn,
            tokenInBalance,
            tokenOutAddress,
            _minAmountOut
        );
    }

    function swapDerivativesToCollateral(
        address _pool,
        address _derivativeIn,
        uint256 _derivativeAmount,
        uint256 _tokenAmountIn,
        address _derivativeOut,
        uint256 _derivativeMinAmountOut
    ) external {


        (IERC20 collateralToken, uint256 collateralAmount) = swapDerivativesToCollateralInternal(
            _pool,
            _derivativeIn,
            _derivativeAmount,
            _tokenAmountIn,
            _derivativeOut,
            _derivativeMinAmountOut
        );

        require(collateralToken.transfer(msg.sender, collateralAmount), "GIVE_COLLATERAL");
    }

    function swapDerivativesToCollateralInternal(
        address _pool,
        address _derivativeIn,
        uint256 _derivativeAmount,
        uint256 _tokenAmountIn,
        address _derivativeOut,
        uint256 _derivativeMinAmountOut
    ) internal returns (IERC20 collateralToken, uint256 collateralAmountOut) {

        Vars memory vars;
        vars.pool = IPool(_pool);

        vars.vault = IVault(vars.pool.derivativeVault());

        vars.primaryToken = IERC20(vars.vault.primaryToken());
        vars.complementToken = IERC20(vars.vault.complementToken());
        vars.collateralToken = IERC20(vars.vault.collateralToken());

        require(
            IERC20(_derivativeIn).transferFrom(msg.sender, address(this), _derivativeAmount),
            "TAKE_IN"
        );

        IERC20(_derivativeIn).approve(_pool, _tokenAmountIn);

        vars.pool.swapExactAmountIn(
            _derivativeIn,
            _tokenAmountIn,
            _derivativeOut,
            _derivativeMinAmountOut
        );

        uint256 primaryTokenAmount = vars.primaryToken.balanceOf(address(this));
        uint256 complementTokenAmount = vars.complementToken.balanceOf(address(this));

        vars.primaryToken.approve(address(vars.vault), primaryTokenAmount);
        vars.complementToken.approve(address(vars.vault), complementTokenAmount);

        uint256 _tokenAmountOut = min(primaryTokenAmount, complementTokenAmount);

        vars.vault.refund(_tokenAmountOut);

        if (vars.primaryToken.balanceOf(address(this)) > 0) {
            vars.primaryToken.transfer(msg.sender, vars.primaryToken.balanceOf(address(this)));
        }

        if (vars.complementToken.balanceOf(address(this)) > 0) {
            vars.complementToken.transfer(
                msg.sender,
                vars.complementToken.balanceOf(address(this))
            );
        }

        collateralAmountOut = vars.collateralToken.balanceOf(address(this));
        collateralToken  = vars.collateralToken;
    }


    function tradeBetweenDerivatives(
        address _poolFromAddress,
        address _derivativeInAddress,
        uint256 _derivativeInAmount,
        uint256 _derivativeInAmountToSell,
        address _derivativeOut,
        uint256 _minTokenOutAmountForFirstSwap,
        address _poolToAddress,
        address _mintedDerivativeToSell,
        uint256 _minTokenOutAmountForSecondSwap
    ) external {


        Vars memory vars;
        vars.pool = IPool(_poolFromAddress);

        vars.vault = IVault(vars.pool.derivativeVault());
        vars.collateralToken = IERC20(vars.vault.collateralToken());

        swapDerivativesToCollateralInternal(
            _poolFromAddress,
            _derivativeInAddress,
            _derivativeInAmount,
            _derivativeInAmountToSell,
            _derivativeOut,
            _minTokenOutAmountForFirstSwap
        );

        uint256 _collateralAmountToMint = vars.collateralToken.balanceOf(address(this));

        (IERC20 tokenOut) = mintAndSwapCollateralToDerivativeInternal(
            _poolToAddress,
            _collateralAmountToMint,
            _mintedDerivativeToSell,
            _minTokenOutAmountForSecondSwap
        );

        uint256 tokenOutBalance = tokenOut.balanceOf(address(this));

        require(tokenOut.transfer(msg.sender, tokenOutBalance), "GIVE_OUT");
    }

     function mintAndJoinPool(
        address _pool,
        uint256 _collateralAmount,
        address _tokenIn,
        uint256 _tokenAmountIn,
        address _tokenOut,
        uint256 _minAmountOut,
        uint256 _minPoolAmountOut
     ) external {

         Vars memory vars;
         vars.pool = IPool(_pool);

         vars.vault = IVault(vars.pool.derivativeVault());

         vars.primaryToken = IERC20(vars.vault.primaryToken());
         vars.complementToken = IERC20(vars.vault.complementToken());
         vars.collateralToken = IERC20(vars.vault.collateralToken());

         require(
             vars.collateralToken.transferFrom(msg.sender, address(this), _collateralAmount),
             "TAKE_COLLATERAL"
         );

         vars.collateralToken.approve(address(vars.vault), _collateralAmount);

         vars.vault.mintTo(address(this), _collateralAmount);

         if(_tokenAmountIn > 0) {
             IERC20(_tokenIn).approve(_pool, _tokenAmountIn);

             vars.pool.swapExactAmountIn(
                 _tokenIn,
                 _tokenAmountIn,
                 _tokenOut,
                 _minAmountOut
             );
         }

         uint lpTokenSupply = IERC20(address(vars.pool)).totalSupply();
         vars.primaryTokenBalance = vars.pool.getBalance(address(vars.primaryToken));
         vars.complementTokenBalance = vars.pool.getBalance(address(vars.complementToken));
         vars.primaryTokenAmount = vars.primaryToken.balanceOf(address(this));
         vars.complementTokenAmount = vars.complementToken.balanceOf(address(this));

         uint lpTokenMultiplier = 1;
         vars.tokenDecimals = uint(IERC20Metadata(address(vars.collateralToken)).decimals());
         if(vars.tokenDecimals > 0 && vars.tokenDecimals < 18) {
             lpTokenMultiplier = 18 - vars.tokenDecimals;
         }

         uint poolAmountOut = min(
             lpTokenSupply * scaleTo(vars.primaryTokenAmount, lpTokenMultiplier) * BONE / scaleTo(vars.primaryTokenBalance, lpTokenMultiplier),
             lpTokenSupply * scaleTo(vars.complementTokenAmount, lpTokenMultiplier) * BONE / scaleTo(vars.complementTokenBalance, lpTokenMultiplier)
         ) / BONE;

         require(poolAmountOut >= _minPoolAmountOut, "MIN_POOL_AMOUNT_OUT");

         vars.primaryToken.approve(_pool, vars.primaryTokenAmount);
         vars.complementToken.approve(_pool, vars.complementTokenAmount);

         uint256[2] memory tokenBalances;
         tokenBalances[0] = vars.primaryTokenAmount;
         tokenBalances[1] = vars.complementTokenAmount;

         vars.pool.joinPool(poolAmountOut, tokenBalances);

         require(vars.pool.transfer(msg.sender, poolAmountOut), "GIVE_POOL");
     }


    function scaleTo(uint256 _amount, uint256 _decimal) internal returns (uint256) {

        return _amount * (10 ** _decimal);
    }

    function removeLiquidityOnSettledState(
        address _pool,
        uint256 _poolAmountIn,
        uint256[2] calldata _minAmountsOut,
        uint256[] memory _underlyingEndRoundHints
    ) external {


        Vars memory vars;
        vars.pool = IPool(_pool);

        vars.vault = IVault(vars.pool.derivativeVault());

        vars.primaryToken = IERC20(vars.vault.primaryToken());
        vars.complementToken = IERC20(vars.vault.complementToken());
        vars.collateralToken = IERC20(vars.vault.collateralToken());

        require(
            vars.pool.transferFrom(msg.sender, address(this), _poolAmountIn),
            "TAKE_POOL"
        );

        require(vars.pool.approve(_pool, _poolAmountIn), "APPROVE");

        vars.pool.exitPool(_poolAmountIn, _minAmountsOut);

        uint256 primaryTokenAmount = vars.primaryToken.balanceOf(address(this));
        uint256 complementTokenAmount = vars.complementToken.balanceOf(address(this));

        vars.primaryToken.approve(address(vars.vault), primaryTokenAmount);
        vars.complementToken.approve(address(vars.vault), complementTokenAmount);

        vars.vault.redeemTo(
            msg.sender,
            primaryTokenAmount,
            complementTokenAmount,
            _underlyingEndRoundHints
        );
    }

    function removeLiquidityOnLiveOrMintingState(
        address _pool,
        uint256 _poolAmountIn,
        address _tokenIn,
        uint256 _tokenAmountIn,
        uint256 _minAmountOut,
        uint256[2] calldata _minAmountsOut
    ) external {


        Vars memory vars;
        vars.pool = IPool(_pool);

        vars.vault = IVault(vars.pool.derivativeVault());

        vars.primaryToken = IERC20(vars.vault.primaryToken());
        vars.complementToken = IERC20(vars.vault.complementToken());
        vars.collateralToken = IERC20(vars.vault.collateralToken());

        require(
            vars.pool.transferFrom(msg.sender, address(this), _poolAmountIn),
            "TAKE_POOL"
        );

        require(vars.pool.approve(_pool, _poolAmountIn), "APPROVE");

        vars.pool.exitPool(_poolAmountIn, _minAmountsOut);

        if(_tokenAmountIn > 0) {
        }

        vars.primaryTokenAmount = vars.primaryToken.balanceOf(address(this));
        vars.complementTokenAmount = vars.complementToken.balanceOf(address(this));

        uint256 _tokensAmountOut = min(vars.primaryTokenAmount, vars.complementTokenAmount);

        vars.primaryToken.approve(address(vars.vault), _tokensAmountOut);
        vars.complementToken.approve(address(vars.vault), _tokensAmountOut);

        vars.vault.refundTo(msg.sender, _tokensAmountOut);

        if(vars.primaryToken.balanceOf(address(this)) > vars.complementToken.balanceOf(address(this))) {
            vars.primaryToken.transfer(msg.sender, vars.primaryToken.balanceOf(address(this)));
        } else {
            vars.complementToken.transfer(msg.sender, vars.complementToken.balanceOf(address(this)));
        }
    }

    function extractChange(address _pool) external {

        Vars memory vars;
        vars.pool = IPool(_pool);

        vars.vault = IVault(vars.pool.derivativeVault());

        vars.primaryToken = IERC20(vars.vault.primaryToken());
        vars.complementToken = IERC20(vars.vault.complementToken());

        if (vars.primaryToken.balanceOf(address(this)) > 0) {
            vars.primaryToken.transfer(
                msg.sender,
                vars.primaryToken.balanceOf(address(this))
            );
        }

        if (vars.complementToken.balanceOf(address(this)) > 0) {
            vars.complementToken.transfer(
                msg.sender,
                vars.complementToken.balanceOf(address(this))
            );
        }
    }
}