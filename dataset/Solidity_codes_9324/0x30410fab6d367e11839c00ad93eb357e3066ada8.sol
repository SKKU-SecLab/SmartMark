
pragma solidity ^0.8.7;


contract BetHorde {


  function CreatePlayer() external {

    require(players[msg.sender].creation_block == 0, "Player exists");
    players[msg.sender].nonce = 1;
    players[msg.sender].creation_block = block.number;
  }

  function PlaceBet(address house, uint256 odds, uint256 amount_gwei,
                    bytes32 randomness, uint256 nonce,
                    uint256 bet_placed_timestamp) payable external {

    uint256 amount = amount_gwei * 1 gwei;
    require(state.bet_counter < type(uint32).max);
    require(houses[house].pause_block > block.number,
            "House unavailable");
    require(players[msg.sender].creation_block > 0,
            "Create player");
    require(odds > 1 && odds <= 1e6, "Invalid odds");
    require(bet_placed_timestamp > houses[house].last_update_timestamp,
            "House updated");
    require(amount <= players[msg.sender].balance + msg.value,
            "Insufficient funds");
    players[msg.sender].balance = players[msg.sender].balance + msg.value - amount;
    require(nonce > players[msg.sender].nonce
            && nonce <= players[msg.sender].nonce + 10,
            "Nonce");
    require(amount >= houses[house].min_bet, "Bet too low");
    require(amount * odds <= houses[house].max_loss, "Exceeds max loss");
    require(amount * (odds - 1) <= houses[house].balance, "Exceeds house balance");
    state.bet_counter++;
    bets[state.bet_counter] = Bet({
      house: house,
      price_gwei: uint56(amount_gwei),
      timestamp: uint32(block.timestamp),
      player: msg.sender,
      previous_house_bet: houses[house].last_bet,
      next_house_bet: 0,
      odds: uint32(odds),
      randomness: keccak256(abi.encode(players[msg.sender].creation_block, nonce,
                            msg.sender, randomness))
    });
    if(houses[house].first_bet == 0) {
      houses[house].first_bet = state.bet_counter;
    } else {
      bets[houses[house].last_bet].next_house_bet = state.bet_counter;
    }
    houses[house].last_bet = state.bet_counter;
    houses[house].bet_balance += amount * odds;
    houses[house].balance -= (amount * odds) - amount;
    houses[house].active_bets++;
    if(houses[house].balance < houses[house].max_loss) {
      houses[house].last_low_balance_timestamp = block.timestamp;
    }
    
    state.reserved_eth += msg.value;
    state.last_bet_time = block.timestamp;
    players[msg.sender].active_bets++;
    players[msg.sender].nonce = nonce;

    emit BetPlaced(house, state.bet_counter);
  }
  
  function PlayerWithdraw(uint256 amount) external {

    require(players[msg.sender].balance >= amount, "Insufficient funds");
    state.reserved_eth -= amount;
    players[msg.sender].balance -= amount;
    _VerifiedTransfer(msg.sender, amount);
  }

  function ForceBet(uint256 bet_id) external {

    require(bets[bet_id].timestamp + 1 days < block.timestamp, "< 24h old");
    _PlayerWin(bet_id);
    _DeleteBet(bet_id);
  }

  function OpenOrAdjustHouse(bytes32[8] calldata modulus, uint256 max_loss,
                             uint256 min_bet, uint256 take)
           PausedOnly payable external {

    if(houses[msg.sender].pause_block == 0) {
      require(msg.value > 1e8 gwei, "Insufficient funds");
      require(msg.sender != address(0), "Invalid address");
      houses[msg.sender].pause_block = type(uint256).max;
      houses[msg.sender].house_address_index = uint128(state.num_houses);
      house_addresses.push(msg.sender);
      state.num_houses++;
    }
    houses[msg.sender].balance += msg.value;
    houses[msg.sender].modulus = modulus;
    houses[msg.sender].max_loss = max_loss;
    houses[msg.sender].min_bet = min_bet;
    houses[msg.sender].take = take;
    houses[msg.sender].last_update_timestamp = block.timestamp;
    state.reserved_eth += msg.value;
    _ValidateHouseParameters(msg.sender);
  }

  function DecideBet(uint256 bet_id, bytes32[8] memory signed_randomness) external {

    require(bets[bet_id].house == msg.sender, "Must be called by house");
    require(bets[bet_id].randomness ==
            _ExtractSigned(signed_randomness, houses[bets[bet_id].house].modulus),
            "Signature mismatch");
    uint256 pot = uint256(bets[bet_id].price_gwei) * bets[bet_id].odds * 1 gwei;
    if(uint256(keccak256(abi.encode(signed_randomness))) % bets[bet_id].odds == 0) {
      _PlayerWin(bet_id);
    } else {
      houses[msg.sender].bet_balance -= pot;
      houses[msg.sender].balance += pot;
      emit BetResolved(msg.sender, false, uint88(bets[bet_id].odds),
                       bets[bet_id].player, uint96(pot));
    }
    _DeleteBet(bet_id);
    houses[msg.sender].completed_bets++;
    uint128 house_idx = houses[msg.sender].house_address_index;
    if(house_idx > 0) {
      house_addresses[house_idx] = house_addresses[house_idx - 1];
      house_addresses[house_idx - 1] = msg.sender;
      houses[msg.sender].house_address_index--;
      houses[house_addresses[house_idx]].house_address_index++;
    }
  }

  function HouseWithdraw(uint256 amount) external PausedOnly {

    require(amount <= houses[msg.sender].balance, "Insufficient funds");
    houses[msg.sender].balance -= amount;
    state.reserved_eth -= amount;
    _VerifiedTransfer(msg.sender, amount);
  }
  
  function FundHouse() external payable HouseExists {

    houses[msg.sender].balance += msg.value;
    state.reserved_eth += msg.value;
  }
  
  function TogglePauseHouse() external HouseExists {

    require(houses[msg.sender].pause_block <= block.number ||
            houses[msg.sender].pause_block == type(uint256).max,
            "Pause pending");
    if(houses[msg.sender].pause_block == type(uint256).max) {
      houses[msg.sender].pause_block = block.number + PAUSE_DELAY_BLOCKS;
    } else {
      houses[msg.sender].pause_block = type(uint256).max;
    }
  }

   constructor() {
    state.owner = msg.sender;
    state.sale_price = type(uint256).max;
    state.last_bet_time = block.timestamp;
  }

  function OwnerWithdraw() external {

    _VerifiedTransfer(state.owner, address(this).balance - state.reserved_eth);
  }
  
  function ChangeOwner(address new_owner) external OnlyOwner {

    state.owner = new_owner;
  }
  
  function BuyContract(uint256 new_price) external payable {

    require(msg.value >= state.sale_price, "Price");
    address owner = state.owner;
    state.owner = msg.sender;
    state.sale_price = new_price;
    _VerifiedTransfer(owner, address(this).balance - state.reserved_eth);
  }
  
  function SetPrice(uint256 sale_price) external OnlyOwner {

    state.sale_price = sale_price;
  }

  function Dismantle() external OnlyOwner {

    require(state.last_bet_time + 90 days < block.timestamp, "90 days");
    selfdestruct(payable(state.owner));
  }

  struct Bet {
    address house;              // House.
    uint56 price_gwei;          // Price of bet in GWEI.
    uint40 timestamp;           // Bet creation time.

    address player;             // Player.
    uint32 previous_house_bet;  // Previous undecided bet for same house.
    uint32 next_house_bet;      // Next undecided bet for same house.

    uint32 odds;                // Odds of winning (odds to 1).

    bytes32 randomness;         // Random value provided by player.
  }

  event BetPlaced(address house, uint32 bet_id);
  event BetResolved(address house, bool player_win, uint88 odds,
                    address player, uint96 pot);
  
  struct House {
    uint256 balance;                     // Available balance (excludes bet_balance).
    uint256 bet_balance;                 // Balance blocked by bets.
    uint256 max_loss;                    // Maximum loss house accepts on one bet.
    uint256 min_bet;                     // Minimum bet price house will accept.
    uint256 take;                        // House take in units of 0.01% (<= 10%).
    bytes32[8] modulus;                  // RSA key modulus.
    uint256 pause_block;                 // Block number for pausing house.

    uint32 first_bet;                    // First undecided bet.
    uint32 last_bet;                     // Last undecided bet.
    uint32 active_bets;                  // Number of active bets.
    uint32 completed_bets;               // Number of decided bets.
    uint128 house_address_index;         // Index in house_addresses.

    uint256 last_update_timestamp;       // Timestamp of last update to house parameters.
    uint256 last_low_balance_timestamp;  // Last time that house balance was below max loss.
  }
  struct Player {
    uint256 balance;         // Available balance (excludes money in active bets).
    uint256 nonce;           // Current nonce (increase by 1 to 10 for each bet).
    uint256 active_bets;     // Number of undecided bets.
    uint256 creation_block;  // Block number of player creation.
    uint256 winnings;        // Total player winnings.
  }
  struct State {
    address owner;          // Contract owner address.
    uint32 bet_counter;     // Total number of bets placed.
    uint64 winnings_micro;  // Total player winnings in micro ETH.
    uint256 reserved_eth;   // ETH reserved in WEI (owner cannot withdraw).
    uint256 sale_price;     // Price to buy contract.
    uint256 last_bet_time;  // Last time that a bet was placed.
    uint256 num_houses;     // Number of houses that have been opened.
  }
  
  mapping(address => House) private houses;
  function ViewHouse(address house) external view returns (House memory) {

    return houses[house];
  }

  mapping(address => Player) public players;

  mapping(uint256 => Bet) public bets;

  address[] public house_addresses;
  State public state;

  function _ValidateHouseParameters(address house_id) internal view {

    require(houses[house_id].min_bet >= 1e4 gwei, "Min bet too low");
    require(houses[house_id].max_loss >= 1e7 gwei, "Max loss too low");  // At least 0.01 ETH
    require(houses[house_id].take <= 1e3, "Take too high");  // Max 10%.
    require(uint256(houses[house_id].modulus[7]) & 1 == 1, "Use prime modulus");
    require(uint256(houses[house_id].modulus[0]) > MIN_MOD, "Use 2048 bit key");
  }
  
  function _VerifiedTransfer(address recipient, uint256 amount) internal {

    (bool success, ) = payable(recipient).call{value: amount}('');
    require(success, "Transfer failed");
  }

  function _GetContractTake(uint256 pot_amount_gwei) internal pure returns (uint256 take_wei) {

    if(pot_amount_gwei < 1e8) {         // < 0.1 ETH: 1% take.
      take_wei = pot_amount_gwei * 1e7;
    } else if(pot_amount_gwei < 1e9) {  // < 1 ETH: 0.5% take.
      take_wei = pot_amount_gwei * 5e6;
    } else if(pot_amount_gwei < 5e9) {  // < 5 ETH: 0.2% take.
      take_wei = pot_amount_gwei * 2e6;
    } else {                            // > 5 ETH: 0.1% take.
      take_wei = pot_amount_gwei * 1e6;
    }
  }
  
  function _PlayerWin(uint256 bet_id) internal {

    uint256 pot = uint256(bets[bet_id].price_gwei) * bets[bet_id].odds;
    uint256 contract_take_wei = _GetContractTake(pot);
    uint256 house_take_wei = pot * houses[bets[bet_id].house].take * 1e5;

    state.winnings_micro += uint64(pot / 1e3);  // Micro ETH to fit in 1e64.
    pot *= 1 gwei;  // Convert to WEI.
    uint256 winnings = pot - contract_take_wei - house_take_wei;
    players[bets[bet_id].player].winnings += winnings;
    players[bets[bet_id].player].balance += winnings;
    houses[bets[bet_id].house].bet_balance -= pot;
    houses[msg.sender].balance += house_take_wei;
    state.reserved_eth -= contract_take_wei;
    
    emit BetResolved(bets[bet_id].house, true, uint88(bets[bet_id].odds),
                     bets[bet_id].player, uint96(pot));
  }
  
  function _DeleteBet(uint256 bet_id) internal {

    uint32 previous = bets[bet_id].previous_house_bet;
    uint32 next = bets[bet_id].next_house_bet;
    if(previous == 0) {
      houses[bets[bet_id].house].first_bet = next;
    } else {
      bets[previous].next_house_bet = next;
    }
    if(next == 0) {
      houses[bets[bet_id].house].last_bet = previous;
    } else {
      bets[next].previous_house_bet = previous;
    }
    houses[bets[bet_id].house].active_bets--;
    players[bets[bet_id].player].active_bets--;
    delete bets[bet_id];
  }

  function _ExtractSigned(bytes32[8] memory signature,
      bytes32[8] memory modulus) internal view returns (bytes32) {

    assembly {
      let ptr:= mload(0x40)
      mstore(ptr, 0x100)             // Signature length (2048 bits).
      mstore(add(ptr, 0x20), 0x20)   // Public exponent length (256 bits).
      mstore(add(ptr, 0x40), 0x100)  // Modulus length (2048 bits).
      mstore(add(ptr, 0x160), 17)    // Public exponent always 17.
      let sigptr := add(ptr, 0x60)   // Signature pointer.
      let modptr := add(ptr, 0x180)  // Modulus pointer.
      for { let i:= 0} lt(i, 0x100) { i := add(i, 0x20) } {
        mstore(add(modptr, i), mload(add(modulus, i)))
        mstore(add(sigptr, i), mload(add(signature, i)))
      }
      if iszero(staticcall(sub(gas(), 2000), 0x05, ptr, 0x280, modulus, 0x100)) {
        revert(0, 0)
      }
    }
    require(
      modulus[0] == SIGNATURE_START &&
      modulus[1] == PADDING_BLOCK &&
      modulus[2] == PADDING_BLOCK &&
      modulus[3] == PADDING_BLOCK &&
      modulus[4] == PADDING_BLOCK &&
      modulus[5] == PADDING_BLOCK &&
      modulus[6] == MESSAGE_PREFIX,
      "Padding");
    return modulus[7];
  }

   modifier HouseExists() {
    require(houses[msg.sender].pause_block > 0, "House does not exist");
    _;
  }

  modifier PausedOnly() {
    require(houses[msg.sender].pause_block < block.number, "Pause house");
    require(houses[msg.sender].active_bets == 0, "Resolve bets");
    _;
  }

  modifier OnlyOwner() {
    require(msg.sender == state.owner, "Owner");
    _;
  }

  uint256 private constant MIN_MOD =
    0x8000000000000000000000000000000000000000000000000000000000000000;
  uint256 private constant PAUSE_DELAY_BLOCKS = 250;
  bytes32 private constant SIGNATURE_START = 
    0x0001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
  bytes32 private constant PADDING_BLOCK =
    0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
  bytes32 private constant MESSAGE_PREFIX =
    0xffffffffffffffffffffffff003031300d060960864801650304020105000420;
  receive() external payable { }
}