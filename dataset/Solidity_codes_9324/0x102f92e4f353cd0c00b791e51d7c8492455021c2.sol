
pragma solidity >=0.6.0 <0.8.0;

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
pragma solidity ^0.7.5;


contract BouncyCoinRefund {


    event Refunded(address addr, uint256 tokenAmount, uint256 ethAmount);

    uint256 public constant MIN_EXCHANGE_RATE = 100000000;

    address payable public owner;

    uint256 public exchangeRate;

    uint256 public totalRefunded;

    IERC20 public bouncyCoinToken; 

    State public state;

    enum State {
        Active,
        Inactive
    }


    modifier atState(State _state) {

        require(state == _state);
        _;
    }

    modifier isOwner() {

        require(msg.sender == owner);
        _;
    }


    constructor(address _bouncyCoinToken, uint256 _exchangeRate)
        public
        payable {
        require(_bouncyCoinToken != address(0));
        require(_exchangeRate >= MIN_EXCHANGE_RATE);

        owner = msg.sender;
        bouncyCoinToken = IERC20(_bouncyCoinToken);
        exchangeRate = _exchangeRate;
        state = State.Inactive;
    }


    fallback() external payable {
    }

    function refund(uint256 _tokenAmount)
        public
        atState(State.Active) {


        uint256 toRefund = _tokenAmount / exchangeRate;
        uint256 bal = address(this).balance;

        uint256 tokensToBurn;
        if (toRefund > bal) {
            tokensToBurn = bal * exchangeRate;
            toRefund = bal;
        } else {
            tokensToBurn = _tokenAmount;
        }

        assert(bouncyCoinToken.transferFrom(msg.sender, address(1), tokensToBurn));
        msg.sender.transfer(toRefund);
        totalRefunded += toRefund;

        emit Refunded(msg.sender, tokensToBurn, toRefund);
    }

    function setExchangeRate(uint256 _exchangeRate)
        public
        isOwner {

        require(_exchangeRate > MIN_EXCHANGE_RATE);

        exchangeRate = _exchangeRate;
    }

    function start()
        public
        isOwner {

        state = State.Active;
    }

    function stop()
        public
        isOwner {

        state = State.Inactive;
    }

    function withdraw()
        public
        isOwner {

        owner.transfer(address(this).balance);
    }

    function transferERC20Token(address _tokenAddress, address _to, uint256 _value)
        public
        isOwner {

        IERC20 token = IERC20(_tokenAddress);
        assert(token.transfer(_to, _value));
    }

}

