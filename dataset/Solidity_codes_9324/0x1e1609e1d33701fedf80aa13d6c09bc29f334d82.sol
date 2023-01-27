

pragma solidity 0.5.0;

interface I_Curve {

    

    function buyPrice(uint256 _amount)
        external
        view
        returns (uint256 collateralRequired);


    function sellReward(uint256 _amount)
        external
        view
        returns (uint256 collateralReward);


    function isCurveActive() external view returns (bool);


    function collateralToken() external view returns (address);


    function bondedToken() external view returns (address);


    function requiredCollateral(uint256 _initialSupply)
        external
        view
        returns (uint256);



    function init() external;


    function mint(uint256 _amount, uint256 _maxCollateralSpend)
        external
        returns (bool success);


    function mintTo(
        uint256 _amount, 
        uint256 _maxCollateralSpend, 
        address _to
    )
        external
        returns (bool success);


    function redeem(uint256 _amount, uint256 _minCollateralReward)
        external
        returns (bool success);


    function shutDown() external;

}


pragma solidity 0.5.0;

interface I_router_02 {

    function WETH() external pure returns (address);


    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

   
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);


    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    )
        external
        returns (uint[] memory amounts);

}


pragma solidity ^0.5.0;

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


pragma solidity 0.5.0;




contract Eth_broker {

    I_Curve internal curve_;
    I_router_02 internal router_;
    IERC20 internal dai_;
    IERC20 internal bzz_;
    uint256 private status_;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;


    event mintTokensWithEth(
        address indexed buyer,      // The address of the buyer
        uint256 amount,             // The amount of bonded tokens to mint
        uint256 priceForTokensDai,  // The price in DAI for the token amount
        uint256 EthTradedForDai,    // The ETH amount sold for DAI
        uint256 maxSpendDai         // The max amount of DAI to spend
    );
    event mintTokensToWithEth(
        address indexed buyer,      // The address of the buyer
        address indexed receiver,   // The address of the receiver of the tokens
        uint256 amount,             // The amount of bonded tokens to mint
        uint256 priceForTokensDai,  // The price in DAI for the token amount
        uint256 EthTradedForDai,    // The ETH amount sold for DAI
        uint256 maxSpendDai         // The max amount of DAI to spend
    );
    event burnTokensWithEth(
        address indexed seller,     // The address of the seller
        uint256 amount,             // The amount of bonded tokens to burn
        uint256 rewardReceivedDai,  // The amount of DAI received for selling
        uint256 ethReceivedForDai,  // How much ETH the DAI was traded for
        uint256 minRewardDai        // The min amount of DAI to sell for
    );


    modifier isCurveActive() {

        require(curve_.isCurveActive(), "Curve inactive");
        _;
    }

    modifier mutex() {

        require(status_ != _ENTERED, "ReentrancyGuard: reentrant call");
        status_ = _ENTERED;
        _;
        status_ = _NOT_ENTERED;
    }


    constructor(
        address _bzzCurve, 
        address _collateralToken, 
        address _router02
    ) 
        public 
    {
        require(
            _bzzCurve != address(0) &&
            _collateralToken != address(0) &&
            _router02 != address(0),
            "Addresses of contracts cannot be 0x address"
        );
        curve_ = I_Curve(_bzzCurve);
        dai_ = IERC20(_collateralToken);
        router_ = I_router_02(_router02);
        bzz_ = IERC20(curve_.bondedToken());
    }


    function buyPrice(uint256 _amount)
        public
        view
        isCurveActive()
        returns (uint256)
    {

        uint256 daiCost = curve_.buyPrice(_amount);
        return router_.getAmountsIn(
            daiCost, 
            getPath(true)
        )[0];
    }

    function sellReward(uint256 _amount)
        public
        view
        isCurveActive()
        returns (uint256)
    {

        uint256 daiReward = curve_.sellReward(_amount);
        return router_.getAmountsIn(
            daiReward, 
            getPath(true)
        )[0];
    }
    
    function sellRewardDai(uint256 _daiAmount)
        public
        view
        isCurveActive()
        returns (uint256)
    {

        return router_.getAmountsIn(
            _daiAmount, 
            getPath(true)
        )[0];
    }
    
    function getPath(bool _buy) public view returns(address[] memory) {

        address[] memory buyPath = new address[](2);
        if(_buy) {
            buyPath[0] = router_.WETH();
            buyPath[1] = address(dai_);
        } else {
            buyPath[0] = address(dai_);
            buyPath[1] = router_.WETH();
        }
        
        return buyPath;
    }
    
    function getTime() public view returns(uint256) {

        return now;
    }


    function mint(
        uint256 _tokenAmount, 
        uint256 _maxDaiSpendAmount, 
        uint _deadline
    )
        external
        payable
        isCurveActive()
        mutex()
        returns (bool)
    {

        (uint256 daiNeeded, uint256 ethReceived) = _commonMint(
            _tokenAmount,
            _maxDaiSpendAmount,
            _deadline,
            msg.sender
        );
        emit mintTokensWithEth(
            msg.sender, 
            _tokenAmount, 
            daiNeeded, 
            ethReceived, 
            _maxDaiSpendAmount
        );
        return true;
    }

    function mintTo(
        uint256 _tokenAmount, 
        uint256 _maxDaiSpendAmount, 
        uint _deadline,
        address _to
    )
        external
        payable
        isCurveActive()
        mutex()
        returns (bool)
    {

        (uint256 daiNeeded, uint256 ethReceived) = _commonMint(
            _tokenAmount,
            _maxDaiSpendAmount,
            _deadline,
            _to
        );
        emit mintTokensToWithEth(
            msg.sender, 
            _to,
            _tokenAmount, 
            daiNeeded, 
            ethReceived, 
            _maxDaiSpendAmount
        );
        return true;
    }

    function redeem(
        uint256 _tokenAmount, 
        uint256 _minDaiSellValue,
        uint _deadline
    )
        external
        payable
        isCurveActive()
        mutex()
        returns (bool)
    {

        uint256 daiReward = curve_.sellReward(_tokenAmount);

        require(
            bzz_.transferFrom(
                msg.sender,
                address(this),
                _tokenAmount
            ),
            "Transferring BZZ failed"
        );
        require(
            bzz_.approve(
                address(curve_),
                _tokenAmount
            ),
            "BZZ approve failed"
        );
        require(
            curve_.redeem(
                _tokenAmount,
                daiReward
            ),
            "Curve burn failed"
        );
        uint256 ethMin = sellRewardDai(dai_.balanceOf(address(this)));
        require(
            dai_.approve(
                address(router_),
                daiReward
            ),
            "DAI approve failed"
        );
        router_.swapExactTokensForETH(
            daiReward, 
            ethMin, 
            getPath(false), 
            msg.sender, 
            _deadline
        );
        emit burnTokensWithEth(
            msg.sender, 
            _tokenAmount, 
            daiReward, 
            ethMin, 
            _minDaiSellValue
        );
        return true;
    }

    function() external payable {
        require(
            msg.sender == address(router_),
            "ETH not accepted outside router"
        );
    }



    function _commonMint(
        uint256 _tokenAmount, 
        uint256 _maxDaiSpendAmount, 
        uint _deadline,
        address _to
    )
        internal
        returns(
            uint256 daiNeeded,
            uint256 ethReceived
        )
    {

        daiNeeded = curve_.buyPrice(_tokenAmount);
        require(
            _maxDaiSpendAmount >= daiNeeded,
            "DAI required for trade above max"
        );
        router_.swapETHForExactTokens.value(msg.value)(
            daiNeeded, 
            getPath(true), 
            address(this), 
            _deadline
        );
        ethReceived = address(this).balance;
        require(
            dai_.approve(address(curve_), daiNeeded),
            "DAI approve failed"
        );
        require(
            curve_.mintTo(_tokenAmount, daiNeeded, _to),
            "BZZ mintTo failed"
        );
        msg.sender.transfer(ethReceived);
    }
}