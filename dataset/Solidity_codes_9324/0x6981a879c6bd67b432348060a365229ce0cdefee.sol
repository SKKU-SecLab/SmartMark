
pragma solidity ^0.5.0;


contract IERC20{

    string public symbol;
    string public name;
    uint256 public totalSupply;
    uint8 public decimals;

    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract timelockTeam {


    IERC20 private _token;

    address private _beneficiary_m;
    address private _beneficiary_s;

    uint256 private _releaseTime;
    
    uint256 private releaseCount = 0;
    uint private releaseQty = 6250000000000000000000000;
    uint private stepTime = 2592000;

    constructor (IERC20 token, address beneficiary_m, address beneficiary_s, uint256 releaseTime) public {
        require(releaseTime > block.timestamp, 'release time is before');
        _token = token;
        _beneficiary_m = beneficiary_m;
        _beneficiary_s = beneficiary_s;
        _releaseTime = releaseTime;
    }

    function token() public view returns (IERC20) {

        return _token;
    }

    function beneficiary() public view returns (address,address) {

        return (_beneficiary_m, _beneficiary_s);
    }

    function releaseTime() public view returns (uint256) {

        return _releaseTime;
    }
    
    function getReleaseCount() public view returns (uint256) {

        return releaseCount;
    }
    
    function balance() public view returns (uint) {

        
        return _token.balanceOf(address(this));
    }

    function release() public {

        require(block.timestamp >= _releaseTime + (stepTime * releaseCount), 'before release time');
        
        uint thisBalance = _token.balanceOf(address(this));
        require(thisBalance > 0, 'release done');
        
        uint currRlease = releaseQty;
        if (thisBalance<releaseQty) {
            currRlease = thisBalance;
        }
        
        uint amount1 = (currRlease * 80) / 100;
        uint amount2 = (currRlease * 20) / 100;
        _token.transfer(_beneficiary_m, amount1);
        _token.transfer(_beneficiary_s, amount2);
        
        releaseCount++;
    }
}