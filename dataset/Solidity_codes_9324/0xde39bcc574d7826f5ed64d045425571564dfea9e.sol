
pragma solidity ^0.4.15;


contract ERC20 {

  function transfer(address _to, uint256 _value) returns (bool success);

  function balanceOf(address _owner) constant returns (uint256 balance);

}

contract RipioFUND {

  mapping (address => uint256) public balances;
  mapping (address => bool) public voters;
  uint256 public for_votes = 0;
  uint256 public agaisnt_votes = 0;


  bytes32 hash_pwd = 0xad7b2f5d7e4850232ccfe2fe22d050eb6c444db4fe374207f901daab8fb7a3a8;
  
  bool public bought_tokens;
  
  uint256 public contract_eth_value;
  
  uint256 constant public min_required_amount = 150 ether;
  uint256 constant public max_amount = 12750 ether;
  
  address public sale = 0x0;

  address constant public creator = 0x9C728ff3Ef531CD2E46aF97c59a809761Ad5c987;
  
  function perform_withdraw(address tokenAddress) {

    require(bought_tokens);
    
    ERC20 token = ERC20(tokenAddress);
    uint256 contract_token_balance = token.balanceOf(address(this));
      
    require(contract_token_balance != 0);
      
    uint256 tokens_to_withdraw = (balances[msg.sender] * contract_token_balance) / contract_eth_value;
      
    contract_eth_value -= balances[msg.sender];
      
    balances[msg.sender] = 0;

    require(token.transfer(msg.sender, tokens_to_withdraw));
  }
  
  function refund_me() {

    require(!bought_tokens);

    uint256 eth_to_withdraw = balances[msg.sender];
      
    balances[msg.sender] = 0;
      
    msg.sender.transfer(eth_to_withdraw);
  }
  
  function buy_the_tokens(string password) {

    if (bought_tokens) return;

    require(hash_pwd == keccak256(password));
    require (for_votes > agaisnt_votes);
    require(this.balance >= min_required_amount);
    require(this.balance <= max_amount);

    require(sale != 0x0);
    
    bought_tokens = true;
    
    contract_eth_value = this.balance;

    sale.transfer(contract_eth_value);
  }

  function change_sale_address(address _sale) {

    require(!bought_tokens);
    require(msg.sender == creator);
    sale = _sale;
    for_votes = 0;
    agaisnt_votes = 0;
  }

  function vote_proposed_address(string string_vote) {

    require(!bought_tokens);
    require(!voters[msg.sender]);
    require(sale != 0x0);
    voters[msg.sender] = true;
    if (keccak256(string_vote) == keccak256("yes")){
      for_votes += 1;
    }
    if (keccak256(string_vote) == keccak256("no")){
      agaisnt_votes += 1;
    }
  }

  function default_helper() payable {

    require(!bought_tokens);
    balances[msg.sender] += msg.value;
  }
  
  function () payable {
    default_helper();
  }
}