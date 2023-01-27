



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
}


pragma solidity ^0.8.3;


contract SOSacrifice {




    event Sacrificed(address indexed from, uint256 total);

    mapping (address => uint256) private _sosacrificed;

    IERC20 private _token;

    address _hak;

    address constant public _dead = 0x000000000000000000000000000000000000dEaD;

    uint256 public _sacrificeTime = 1640710799;
    uint256 public first;
    uint256 public second;
    uint256 public third;

    constructor (IERC20 token_) {
        _token = token_;
        _hak = msg.sender;
    }

    function sacrifice(uint256 amount_) external {

        require(
            block.timestamp >= _sacrificeTime,
            "sacrifice not open"
        );
        address from = msg.sender;
        _token.transferFrom(from, _dead, amount_ / 2);
        _token.transferFrom(from, _hak, amount_ / 2);

        uint256 original = _sosacrificed[from];
        uint256 total = original + amount_;
        _sosacrificed[from] = total;

        if (total > first){
            first = total;
        } else if (total > second){
            second = total;
        } else if (total > third){
            third = total;
        }

        emit Sacrificed(from, total);
    }

    function sacrificedAmount(address addr) external view returns (uint256) {

        return _sosacrificed[addr];
    }

    modifier onlyHak() {

        require(msg.sender == _hak, "msg.sender is not hak");
        _;
    }

    function setHak(address hak_) external onlyHak {

        _hak = hak_;
    }

    function setTime(uint256 time_) external onlyHak {

        _sacrificeTime = time_;
    }
}