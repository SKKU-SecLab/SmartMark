
pragma solidity ^0.4.21;
 
interface HourglassInterface {

    function() payable external;
    function buy(address _playerAddress) payable external returns(uint256);

    function sell(uint256 _amountOfTokens) external;

    function reinvest() external;

    function withdraw() external;

    function exit() external;

    function dividendsOf(address _playerAddress, bool) external view returns(uint256);

    function balanceOf(address _playerAddress) external view returns(uint256);

    function transfer(address _toAddress, uint256 _amountOfTokens) external returns(bool);

    function stakingRequirement() external view returns(uint256);

}

contract Divies {

    using SafeMath for uint256;
    using UintCompressor for uint256;
    address private eWLTHAddress = 0x5833C959C3532dD5B3B6855D590D70b01D2d9fA6;

    HourglassInterface constant eWLTH = HourglassInterface(eWLTHAddress);
    
    uint256 public pusherTracker_ = 100;
    mapping (address => Pusher) public pushers_;
    struct Pusher
    {
        uint256 tracker;
        uint256 time;
    }

    function balances()
        public
        view
        returns(uint256)
    {

        return (address(this).balance);
    }
    
    
    function deposit()
        external
        payable
    {

        
    }
    
    function() external payable {}
    
    
    event onDistribute(
        address pusher,
        uint256 startingBalance,
        uint256 finalBalance,
        uint256 compressedData
    );
    
    
    function distribute()
        public
    {

        uint256 _percent = 75;
        address _pusher = msg.sender;
        uint256 _bal = address(this).balance;
        uint256 _compressedData;
        
        pushers_[_pusher].tracker = pusherTracker_;
        pusherTracker_++;
            
        uint256 _stop = (_bal.mul(100 - _percent)) / 100;
            
        eWLTH.buy.value(_bal)(address(0));
        eWLTH.sell(eWLTH.balanceOf(address(this)));
            
        uint256 _tracker = eWLTH.dividendsOf(address(this), true);
    
        while (_tracker >= _stop) 
        {
            eWLTH.reinvest();
            eWLTH.sell(eWLTH.balanceOf(address(this)));
                
            _tracker = (_tracker.mul(81)) / 100;
        }
            
        eWLTH.withdraw();
        
        pushers_[_pusher].time = now;
    
        _compressedData = _compressedData.insert(now, 0, 14);
        _compressedData = _compressedData.insert(pushers_[_pusher].tracker, 15, 29);
        _compressedData = _compressedData.insert(pusherTracker_, 30, 44);

        emit onDistribute(_pusher, _bal, address(this).balance, _compressedData);
    }
}


library UintCompressor {

    using SafeMath for *;
    
    function insert(uint256 _var, uint256 _include, uint256 _start, uint256 _end)
        internal
        pure
        returns(uint256)
    {

        require(_end < 77 && _start < 77);
        require(_end >= _start);
        
        _end = exponent(_end).mul(10);
        _start = exponent(_start);
        
        require(_include < (_end / _start));
        
        if (_include > 0)
            _include = _include.mul(_start);
        
        return((_var.sub((_var / _start).mul(_start))).add(_include).add((_var / _end).mul(_end)));
    }
    
    function extract(uint256 _input, uint256 _start, uint256 _end)
	    internal
	    pure
	    returns(uint256)
    {

        require(_end < 77 && _start < 77);
        require(_end >= _start);
        
        _end = exponent(_end).mul(10);
        _start = exponent(_start);
        
        return((((_input / _start).mul(_start)).sub((_input / _end).mul(_end))) / _start);
    }
    
    function exponent(uint256 _position)
        private
        pure
        returns(uint256)
    {

        return((10).pwr(_position));
    }
}

library SafeMath {

    
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b);
        return c;
    }

    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {

        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {

        c = a + b;
        require(c >= a);
        return c;
    }
    
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {

        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {

        return (mul(x,x));
    }
    
    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {

        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else 
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}