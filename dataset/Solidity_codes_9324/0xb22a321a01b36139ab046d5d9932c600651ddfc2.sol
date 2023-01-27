
pragma solidity ^0.4.19;



interface ChiToken {

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

}

contract ChiTrader {

    ChiToken Chi = ChiToken(0x71E1f8E809Dc8911FCAC95043bC94929a36505A5); // hardcoded Chi address to avoid scams.
    address public seller;
    uint256 public price; // price is in wei, not ether
    uint256 public Chi_available; // remaining amount of Chi. This is just a convenience variable for buyers, not really used in the contract.
    uint256 public Amount_of_Chi_for_One_ETH; // shows how much Chi you get for 1 ETH. Helps avoid price scams.
    uint256 cooldown_start_time;

    function ChiTrader() public {

        seller = 0x0;
        price = 0;
        Chi_available = 0;
        Amount_of_Chi_for_One_ETH = 0;
        cooldown_start_time = 0;
    }

    function is_empty() public view returns (bool) {

        return (now - cooldown_start_time > 1 hours) && (this.balance==0) && (Chi.balanceOf(this) == 0);
    }
    
    function setup(uint256 chi_amount, uint256 price_in_wei) public {

        require(is_empty()); // must not be in cooldown
        require(Chi.allowance(msg.sender, this) >= chi_amount); // contract needs enough allowance
        require(price_in_wei > 1000); // to avoid mistakes, require price to be more than 1000 wei
        
        price = price_in_wei;
        Chi_available = chi_amount;
        Amount_of_Chi_for_One_ETH = 1 ether / price_in_wei;
        seller = msg.sender;

        require(Chi.transferFrom(msg.sender, this, chi_amount)); // move Chi to this contract to hold in escrow
    }

    function() public payable{
        uint256 eth_balance = this.balance;
        uint256 chi_balance = Chi.balanceOf(this);
        if(msg.sender == seller){
            seller = 0x0; // reset seller
            price = 0; // reset price
            Chi_available = 0; // reset available chi
            Amount_of_Chi_for_One_ETH = 0; // reset price
            cooldown_start_time = now; // start cooldown timer

            if(eth_balance > 0) msg.sender.transfer(eth_balance); // withdraw all ETH
            if(chi_balance > 0) require(Chi.transfer(msg.sender, chi_balance)); // withdraw all Chi
        }        
        else{
            require(msg.value > 0); // must send some ETH to buy Chi
            require(price > 0); // cannot divide by zero
            uint256 num_chi = msg.value / price; // calculate number of Chi tokens for the ETH amount sent
            require(chi_balance >= num_chi); // must have enough Chi in the contract
            Chi_available = chi_balance - num_chi; // recalculate available Chi

            require(Chi.transfer(msg.sender, num_chi)); // send Chi to buyer
        }
    }
}