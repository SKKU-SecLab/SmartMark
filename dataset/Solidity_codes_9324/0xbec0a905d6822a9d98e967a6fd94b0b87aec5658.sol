
pragma solidity ^0.5.0;


interface ERC20 {

    function totalSupply() external view returns (uint256 supply);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function transfer(address _to, uint256 _value) external returns (bool success);


    function transferFrom(address _from, address _to, uint256 _value)
        external
        returns (bool success);


    function approve(address _spender, uint256 _value) external returns (bool success);


    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


    function decimals() external view returns (uint256 digits);


    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

interface ExchangeInterface {

    function swapEtherToToken(uint256 _ethAmount, address _tokenAddress, uint256 _maxAmount)
        external
        payable
        returns (uint256, uint256);


    function swapTokenToEther(address _tokenAddress, uint256 _amount, uint256 _maxAmount)
        external
        returns (uint256);


    function swapTokenToToken(address _src, address _dest, uint256 _amount)
        external
        payable
        returns (uint256);


    function getExpectedRate(address src, address dest, uint256 srcQty)
        external
        view
        returns (uint256 expectedRate);

}

contract TokenInterface {

    function allowance(address, address) public returns (uint256);


    function balanceOf(address) public returns (uint256);


    function approve(address, uint256) public;


    function transfer(address, uint256) public returns (bool);


    function transferFrom(address, address, uint256) public returns (bool);


    function deposit() public payable;


    function withdraw(uint256) public;

}

contract DSMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x);
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x / y;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x >= y ? x : y;
    }

    function imin(int256 x, int256 y) internal pure returns (int256 z) {

        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {

        return x >= y ? x : y;
    }

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, WAD), y / 2) / y;
    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract SaverExchangeConstantAddresses {

    address public constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address payable public constant WALLET_ID = 0x322d58b9E75a6918f7e7849AEe0fF09369977e08;
    address public constant DISCOUNT_ADDRESS = 0x1b14E8D511c9A4395425314f849bD737BAF8208F;

    address public constant KYBER_WRAPPER = 0x8F337bD3b7F2b05d9A8dC8Ac518584e833424893;
    address public constant UNISWAP_WRAPPER = 0x1e30124FDE14533231216D95F7798cD0061e5cf8;
    address public constant OASIS_WRAPPER = 0x891f5A171f865031b0f3Eb9723bb8f68C901c9FE;

    
    address public constant ERC20_PROXY_0X = 0x95E6F48254609A6ee006F7D493c8e5fB97094ceF;
}

contract Discount {

    address public owner;
    mapping(address => CustomServiceFee) public serviceFees;

    uint256 constant MAX_SERVICE_FEE = 400;

    struct CustomServiceFee {
        bool active;
        uint256 amount;
    }

    constructor() public {
        owner = msg.sender;
    }

    function isCustomFeeSet(address _user) public view returns (bool) {

        return serviceFees[_user].active;
    }

    function getCustomServiceFee(address _user) public view returns (uint256) {

        return serviceFees[_user].amount;
    }

    function setServiceFee(address _user, uint256 _fee) public {

        require(msg.sender == owner, "Only owner");
        require(_fee >= MAX_SERVICE_FEE || _fee == 0);

        serviceFees[_user] = CustomServiceFee({active: true, amount: _fee});
    }

    function disableServiceFee(address _user) public {

        require(msg.sender == owner, "Only owner");

        serviceFees[_user] = CustomServiceFee({active: false, amount: 0});
    }
}

contract SaverExchange is DSMath, SaverExchangeConstantAddresses {

    uint256 public constant SERVICE_FEE = 800; 

    event Swap(
        address src,
        address dest,
        uint256 amountSold,
        uint256 amountBought,
        address wrapper
    );

    function swapTokenToToken(
        address _src,
        address _dest,
        uint256 _amount,
        uint256 _minPrice,
        uint256 _exchangeType,
        address _exchangeAddress,
        bytes memory _callData,
        uint256 _0xPrice
    ) public payable {

        
        address[3] memory orderAddresses = [_exchangeAddress, _src, _dest];

        if (orderAddresses[1] == KYBER_ETH_ADDRESS) {
            require(msg.value >= _amount, "msg.value smaller than amount");
        } else {
            require(
                ERC20(orderAddresses[1]).transferFrom(msg.sender, address(this), _amount),
                "Not able to withdraw wanted amount"
            );
        }

        uint256 fee = takeFee(_amount, orderAddresses[1]);
        _amount = sub(_amount, fee);
        
        uint256[2] memory tokens;
        address wrapper;
        uint256 price;
        bool success;

        
        tokens[1] = _amount;

        if (_exchangeType == 4) {
            if (orderAddresses[1] != KYBER_ETH_ADDRESS) {
                ERC20(orderAddresses[1]).approve(address(ERC20_PROXY_0X), _amount);
            }

            (success, tokens[0], ) = takeOrder(
                orderAddresses,
                _callData,
                address(this).balance,
                _amount
            );
            
            require(success && tokens[0] > 0, "0x transaction failed");
            wrapper = address(_exchangeAddress);
        }

        if (tokens[0] == 0) {
            (wrapper, price) = getBestPrice(
                _amount,
                orderAddresses[1],
                orderAddresses[2],
                _exchangeType
            );

            require(price > _minPrice || _0xPrice > _minPrice, "Slippage hit");

            
            if (_0xPrice >= price) {
                if (orderAddresses[1] != KYBER_ETH_ADDRESS) {
                    ERC20(orderAddresses[1]).approve(address(ERC20_PROXY_0X), _amount);
                }
                (success, tokens[0], tokens[1]) = takeOrder(
                    orderAddresses,
                    _callData,
                    address(this).balance,
                    _amount
                );
                
                if (success && tokens[0] > 0) {
                    wrapper = address(_exchangeAddress);
                    emit Swap(orderAddresses[1], orderAddresses[2], _amount, tokens[0], wrapper);
                }
            }

            if (tokens[1] > 0) {
                
                if (tokens[1] != _amount) {
                    (wrapper, price) = getBestPrice(
                        tokens[1],
                        orderAddresses[1],
                        orderAddresses[2],
                        _exchangeType
                    );
                }

                
                require(price > _minPrice, "Slippage hit onchain price");
                if (orderAddresses[1] == KYBER_ETH_ADDRESS) {
                    (tokens[0], ) = ExchangeInterface(wrapper).swapEtherToToken.value(tokens[1])(
                        tokens[1],
                        orderAddresses[2],
                        uint256(-1)
                    );
                } else {
                    ERC20(orderAddresses[1]).transfer(wrapper, tokens[1]);

                    if (orderAddresses[2] == KYBER_ETH_ADDRESS) {
                        tokens[0] = ExchangeInterface(wrapper).swapTokenToEther(
                            orderAddresses[1],
                            tokens[1],
                            uint256(-1)
                        );
                    } else {
                        tokens[0] = ExchangeInterface(wrapper).swapTokenToToken(
                            orderAddresses[1],
                            orderAddresses[2],
                            tokens[1]
                        );
                    }
                }

                emit Swap(orderAddresses[1], orderAddresses[2], _amount, tokens[0], wrapper);
            }
        }

        
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }

        
        if (orderAddresses[2] != KYBER_ETH_ADDRESS) {
            if (ERC20(orderAddresses[2]).balanceOf(address(this)) > 0) {
                ERC20(orderAddresses[2]).transfer(
                    msg.sender,
                    ERC20(orderAddresses[2]).balanceOf(address(this))
                );
            }
        }

        if (orderAddresses[1] != KYBER_ETH_ADDRESS) {
            if (ERC20(orderAddresses[1]).balanceOf(address(this)) > 0) {
                ERC20(orderAddresses[1]).transfer(
                    msg.sender,
                    ERC20(orderAddresses[1]).balanceOf(address(this))
                );
            }
        }
    }

    
    
    
    
    
    function takeOrder(
        address[3] memory _addresses,
        bytes memory _data,
        uint256 _value,
        uint256 _amount
    ) private returns (bool, uint256, uint256) {

        bool success;

        
        (success, ) = _addresses[0].call.value(_value)(_data);

        uint256 tokensLeft = _amount;
        uint256 tokensReturned = 0;
        if (success) {
            
            if (_addresses[1] == KYBER_ETH_ADDRESS) {
                tokensLeft = address(this).balance;
            } else {
                tokensLeft = ERC20(_addresses[1]).balanceOf(address(this));
            }

            
            if (_addresses[2] == KYBER_ETH_ADDRESS) {
                TokenInterface(WETH_ADDRESS).withdraw(
                    TokenInterface(WETH_ADDRESS).balanceOf(address(this))
                );
                tokensReturned = address(this).balance;
            } else {
                tokensReturned = ERC20(_addresses[2]).balanceOf(address(this));
            }
        }

        return (success, tokensReturned, tokensLeft);
    }

    
    
    
    
    
    function getBestPrice(
        uint256 _amount,
        address _srcToken,
        address _destToken,
        uint256 _exchangeType
    ) public returns (address, uint256) {

        uint256 expectedRateKyber;
        uint256 expectedRateUniswap;
        uint256 expectedRateOasis;

        if (_exchangeType == 1) {
            return (OASIS_WRAPPER, getExpectedRate(OASIS_WRAPPER, _srcToken, _destToken, _amount));
        }

        if (_exchangeType == 2) {
            return (KYBER_WRAPPER, getExpectedRate(KYBER_WRAPPER, _srcToken, _destToken, _amount));
        }

        if (_exchangeType == 3) {
            expectedRateUniswap = getExpectedRate(UNISWAP_WRAPPER, _srcToken, _destToken, _amount);
            expectedRateUniswap = expectedRateUniswap * (10**(18 - getDecimals(_destToken)));
            return (UNISWAP_WRAPPER, expectedRateUniswap);
        }

        expectedRateKyber = getExpectedRate(KYBER_WRAPPER, _srcToken, _destToken, _amount);
        expectedRateUniswap = getExpectedRate(UNISWAP_WRAPPER, _srcToken, _destToken, _amount);
        expectedRateUniswap = expectedRateUniswap * (10**(18 - getDecimals(_destToken)));
        expectedRateOasis = getExpectedRate(OASIS_WRAPPER, _srcToken, _destToken, _amount);
        expectedRateOasis = expectedRateOasis * (10**(18 - getDecimals(_destToken)));

        if (
            (expectedRateKyber >= expectedRateUniswap) && (expectedRateKyber >= expectedRateOasis)
        ) {
            return (KYBER_WRAPPER, expectedRateKyber);
        }

        if (
            (expectedRateOasis >= expectedRateKyber) && (expectedRateOasis >= expectedRateUniswap)
        ) {
            return (OASIS_WRAPPER, expectedRateOasis);
        }

        if (
            (expectedRateUniswap >= expectedRateKyber) && (expectedRateUniswap >= expectedRateOasis)
        ) {
            return (UNISWAP_WRAPPER, expectedRateUniswap);
        }
    }

    function getExpectedRate(
        address _wrapper,
        address _srcToken,
        address _destToken,
        uint256 _amount
    ) public returns (uint256) {

        bool success;
        bytes memory result;

        (success, result) = _wrapper.call(
            abi.encodeWithSignature(
                "getExpectedRate(address,address,uint256)",
                _srcToken,
                _destToken,
                _amount
            )
        );

        if (success) {
            return sliceUint(result, 0);
        } else {
            return 0;
        }
    }

    
    
    
    function takeFee(uint256 _amount, address _token) internal returns (uint256 feeAmount) {

        uint256 fee = SERVICE_FEE;

        if (Discount(DISCOUNT_ADDRESS).isCustomFeeSet(msg.sender)) {
            fee = Discount(DISCOUNT_ADDRESS).getCustomServiceFee(msg.sender);
        }

        if (fee == 0) {
            feeAmount = 0;
        } else {
            feeAmount = _amount / SERVICE_FEE;
            if (_token == KYBER_ETH_ADDRESS) {
                WALLET_ID.transfer(feeAmount);
            } else {
                ERC20(_token).transfer(WALLET_ID, feeAmount);
            }
        }
    }

    function getDecimals(address _token) internal view returns (uint256) {

        
        if (_token == address(0xE0B7927c4aF23765Cb51314A0E0521A9645F0E2A)) {
            return 9;
        }
        
        if (_token == address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)) {
            return 6;
        }
        
        if (_token == address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599)) {
            return 8;
        }

        return 18;
    }

    function sliceUint(bytes memory bs, uint256 start) internal pure returns (uint256) {

        require(bs.length >= start + 32, "slicing out of range");

        uint256 x;
        assembly {
            x := mload(add(bs, add(0x20, start)))
        }

        return x;
    }

    
    function() external payable {}
}