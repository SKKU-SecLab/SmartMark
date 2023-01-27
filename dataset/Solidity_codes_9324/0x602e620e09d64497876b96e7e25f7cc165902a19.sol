

pragma solidity ^0.6.8;

interface Erc20 {

    function balanceOf(address _owner) external view returns(uint256);


    function transfer(address _to, uint256 _value) external returns (bool);


    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

}

contract Exchange {

    address public token;

    event Buy(address _buyer, uint256 _wei);

    event Sell(address _seller, uint256 _wei);

    constructor(address _token) public {
        token = _token;
    }

    fallback() external payable {
        emit Buy(msg.sender, msg.value);
    }

    function buy(uint256 _tokens) public payable {

        require(msg.value >= weiToBuy(_tokens), "not enough wei");
        Erc20(token).transfer(msg.sender, _tokens);

        emit Buy(msg.sender, msg.value);
    }

    function sell(uint256 _tokens) public {

        uint256 weiToPay = weiFromSell(_tokens);
        require(weiToPay > 0, "small _tokens");
        require(weiToPay <= address(this).balance, "not enough wei");
        Erc20(token).transferFrom(msg.sender, address(this), _tokens);

        msg.sender.transfer(weiToPay);

        emit Sell(msg.sender, weiToPay);
    }

    function clean(address _contract, uint256 _value) public {

        require(_contract != token, "no _contract");
        Erc20(_contract).transfer(msg.sender, _value);
    }

    function price() public view returns(uint256) {

        return 10**18 - Erc20(token).balanceOf(address(this)) / 10000000;
    }

    function weiToBuy(uint256 _tokens) public view returns(uint256) {

        require(_tokens < 10**23, "big _tokens");
        uint256 price = price() + _tokens / 20000000;
        return price * _tokens / 10**18;
    }

    function weiFromSell(uint256 _tokens) public view returns(uint256) {

        require(_tokens < 10**23, "big _tokens");
        uint256 price = price() - _tokens / 20000000;
        return price * _tokens / 10**18;
    }
}