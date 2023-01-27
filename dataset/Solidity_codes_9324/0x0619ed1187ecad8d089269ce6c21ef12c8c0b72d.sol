pragma solidity 0.5.8;


contract ERC20Basic {

  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}
pragma solidity 0.5.8;




contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity 0.5.8;

library ECVerify {


    function ecverify(bytes32 hash, bytes memory signature) internal pure returns (address signature_address) {

        require(signature.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))

            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28);

        signature_address = ecrecover(hash, v, r, s);

        require(signature_address != address(0x0));

        return signature_address;
    }
}
pragma solidity 0.5.8;


library SafeMath64 {


  function mul(uint64 a, uint64 b) internal pure returns (uint64) {

    if (a == 0) {
      return 0;
    }
    uint64 c = a * b;
    assert(c / a == b);
    return c;
  }

  function sub(uint64 a, uint64 b) internal pure returns (uint64) {

    assert(b <= a);
    return a - b;
  }

  function add(uint64 a, uint64 b) internal pure returns (uint64) {

    uint64 c = a + b;
    assert(c >= a);
    return c;
  }
}
pragma solidity 0.5.8;


contract PrivatixServiceContract {

    using SafeMath64 for uint64;


    uint32 public popup_period;

    uint32 public challenge_period;

    uint32 public remove_period;

    uint32 public network_fee;
    
    address public network_fee_address;

    uint64 public constant channel_deposit_bugbounty_limit = 10 ** 8 * 300;

    ERC20 public token;

    mapping (bytes32 => Channel) private channels;
    mapping (bytes32 => ClosingRequest) private closing_requests;
    mapping (address => uint64) private internal_balances;
    mapping(bytes32 => ServiceOffering) private service_offering_s;

    struct ServiceOffering{
      uint64 min_deposit;  // bytes8 - Minimum deposit that Client should place to open state channel.
      address agent_address; //bytes20 - Address of Agent.
      uint16 max_supply; // bytes2 - Maximum supply of services according to service offerings.
      uint16 current_supply; // bytes2 - Currently remaining available supply.

      uint32 update_block_number;
    }

    struct Channel {
        uint64 deposit;

        uint32 open_block_number;
    }

    struct ClosingRequest {
        uint64 closing_balance;

        uint32 settle_block_number;
    }


    event LogChannelCreated(
        address indexed _agent,
        address indexed _client,
        bytes32 indexed _offering_hash,
        uint64 _deposit);
    event LogChannelToppedUp(
        address indexed _agent,
        address indexed _client,
        bytes32 indexed _offering_hash,
        uint32 _open_block_number,
        uint64 _added_deposit);
    event LogChannelCloseRequested(
        address indexed _agent,
        address indexed _client,
        bytes32 indexed _offering_hash,
        uint32 _open_block_number,
        uint64 _balance);
    event LogOfferingCreated(
        address indexed _agent,
        bytes32 indexed _offering_hash,
        uint64 indexed _min_deposit,
        uint16 _current_supply,
        uint8 _source_type,
        string _source);
    event LogOfferingDeleted(
      address indexed _agent,
      bytes32 indexed _offering_hash);
    event LogOfferingPopedUp(
      address indexed _agent,
      bytes32 indexed _offering_hash,
      uint64 indexed _min_deposit,
      uint16 _current_supply,
      uint8 _source_type,
      string _source);
    event LogCooperativeChannelClose(
      address indexed _agent,
      address indexed _client,
      bytes32 indexed _offering_hash,
      uint32 _open_block_number,
      uint64 _balance);
    event LogUnCooperativeChannelClose(
      address indexed _agent,
      address indexed _client,
      bytes32 indexed _offering_hash,
      uint32 _open_block_number,
      uint64 _balance);



    constructor(
      address _token_address,
      address _network_fee_address,
      uint32 _popup_period,
      uint32 _remove_period,
      uint32 _challenge_period
      ) public {
        require(_token_address != address(0x0));
        require(addressHasCode(_token_address));
        require(_network_fee_address != address(0x0));
        require(_remove_period >= 100);
        require(_popup_period >= 500);
        require(_challenge_period >= 5000);

        token = ERC20(_token_address);

        require(token.totalSupply() > 0);

        network_fee_address = _network_fee_address;
        popup_period = _popup_period;
        remove_period = _remove_period;
        challenge_period = _challenge_period;

    }


    function addBalanceERC20(uint64 _value) external {

      internal_balances[msg.sender] = internal_balances[msg.sender].add(_value);
      require(token.transferFrom(msg.sender, address(this), _value));
    }

    function returnBalanceERC20(uint64 _value) external {

      internal_balances[msg.sender] = internal_balances[msg.sender].sub(_value); // test S21
      require(token.transfer(msg.sender, _value));
    }

    function balanceOf(address _address) external view
    returns(uint64)
    {

      return (internal_balances[_address]); // test U1
    }

    function setNetworkFeeAddress(address _network_fee_address) external { // test S24

        require(msg.sender == network_fee_address);
        network_fee_address = _network_fee_address;
    }

    function setNetworkFee(uint32 _network_fee) external { // test S22

        require(msg.sender == network_fee_address);
        require(_network_fee <= 10000); // test S23
        network_fee = _network_fee;
    }

    function createChannel(address _agent_address, bytes32 _offering_hash, uint64 _deposit) external {

        require(_deposit >= service_offering_s[_offering_hash].min_deposit); // test S4
        require(internal_balances[msg.sender] >= _deposit); // test S5

        decreaseOfferingSupply(_agent_address, _offering_hash);
        createChannelPrivate(msg.sender, _agent_address, _offering_hash, _deposit);
        internal_balances[msg.sender] = internal_balances[msg.sender].sub(_deposit); //test S5
        emit LogChannelCreated(_agent_address, msg.sender, _offering_hash, _deposit); //test E1
    }

    function topUpChannel(
        address _agent_address,
        uint32 _open_block_number,
        bytes32 _offering_hash,
        uint64 _added_deposit)
        external
    {

        updateInternalBalanceStructs(
            msg.sender,
            _agent_address,
            _open_block_number,
            _offering_hash,
            _added_deposit
        );

        internal_balances[msg.sender] = internal_balances[msg.sender].sub(_added_deposit);
    }

    function cooperativeClose(
        address _agent_address,
        uint32 _open_block_number,
        bytes32 _offering_hash,
        uint64 _balance,
        bytes calldata _balance_msg_sig,
        bytes calldata _closing_sig)
        external
    {

        address sender = extractSignature(_agent_address, _open_block_number, _offering_hash, _balance, _balance_msg_sig, true);

        address receiver = extractSignature(sender, _open_block_number, _offering_hash, _balance, _closing_sig, false);
        require(receiver == _agent_address); // tests S6, I1a-I1f

        settleChannel(sender, receiver, _open_block_number, _offering_hash, _balance);
        emit LogCooperativeChannelClose(receiver, sender, _offering_hash, _open_block_number, _balance); // test E7
    }

    function uncooperativeClose(
        address _agent_address,
        uint32 _open_block_number,
        bytes32 _offering_hash,
        uint64 _balance)
        external
    {

        bytes32 key = getKey(msg.sender, _agent_address, _open_block_number, _offering_hash);

        require(channels[key].open_block_number > 0); // test S9
        require(closing_requests[key].settle_block_number == 0); // test S10
        require(_balance <= channels[key].deposit); // test S11

        closing_requests[key].settle_block_number = uint32(block.number) + challenge_period;
        require(closing_requests[key].settle_block_number > block.number);
        closing_requests[key].closing_balance = _balance;

        emit LogChannelCloseRequested(_agent_address, msg.sender, _offering_hash, _open_block_number, _balance); // test E3
    }


    function settle(address _agent_address, uint32 _open_block_number, bytes32 _offering_hash) external {

        bytes32 key = getKey(msg.sender, _agent_address, _open_block_number, _offering_hash);

        require(closing_requests[key].settle_block_number > 0); // test S7

        require(block.number > closing_requests[key].settle_block_number); // test S8
        uint64 balance = closing_requests[key].closing_balance;
        settleChannel(msg.sender, _agent_address, _open_block_number, _offering_hash,
           closing_requests[key].closing_balance
        );

        emit LogUnCooperativeChannelClose(_agent_address, msg.sender, _offering_hash,
           _open_block_number, balance
        ); // test E9
    }

    function getChannelInfo(
        address _client_address,
        address _agent_address,
        uint32 _open_block_number,
        bytes32 _offering_hash)
        external
        view
        returns (uint64, uint32, uint64)
    {

        bytes32 key = getKey(_client_address, _agent_address, _open_block_number, _offering_hash);

        return (
            channels[key].deposit,
            closing_requests[key].settle_block_number,
            closing_requests[key].closing_balance
        );
    }

    function getOfferingInfo(bytes32 offering_hash)
        external
        view
        returns(address, uint64, uint16, uint16, uint32)
    {

        ServiceOffering memory offering = service_offering_s[offering_hash];
        return (offering.agent_address,
                offering.min_deposit,
                offering.max_supply,
                offering.current_supply,
                offering.update_block_number
        );
    }



    function registerServiceOffering (
     bytes32 _offering_hash,
     uint64 _min_deposit,
     uint16 _max_supply,
     uint8 _source_type,
     string calldata _source)
     external
    {
      require(service_offering_s[_offering_hash].update_block_number == 0);

      require(_min_deposit.mul(_max_supply) < channel_deposit_bugbounty_limit);
      require(_min_deposit > 0); // zero deposit is not allowed, test S3

      service_offering_s[_offering_hash] = ServiceOffering(_min_deposit,
                                                           msg.sender,
                                                           _max_supply,
                                                           _max_supply,
                                                           uint32(block.number)
                                                          );

      internal_balances[msg.sender] = internal_balances[msg.sender].sub(_min_deposit.mul(_max_supply)); // test S26

      emit LogOfferingCreated(msg.sender, _offering_hash, _min_deposit, _max_supply, _source_type, _source); // test E4
    }

    function removeServiceOffering (
     bytes32 _offering_hash)
     external
    {
      require(service_offering_s[_offering_hash].update_block_number > 0); // test S13
      assert(service_offering_s[_offering_hash].agent_address == msg.sender); // test S14
      require(service_offering_s[_offering_hash].update_block_number + remove_period < block.number); // test S15
      internal_balances[msg.sender] = internal_balances[msg.sender].add(

        service_offering_s[_offering_hash].min_deposit * service_offering_s[_offering_hash].max_supply

      );
      service_offering_s[_offering_hash].update_block_number = 0;

      emit LogOfferingDeleted(msg.sender, _offering_hash); // test E5
    }

    function popupServiceOffering (
        bytes32 _offering_hash,
        uint8 _source_type,
        string calldata _source)
    external
    {
      require(service_offering_s[_offering_hash].update_block_number > 0); // Service offering already exists, test S16
      require(service_offering_s[_offering_hash].update_block_number + popup_period < block.number); // test S16a
      require(service_offering_s[_offering_hash].agent_address == msg.sender); // test S17

      ServiceOffering memory offering = service_offering_s[_offering_hash];
      service_offering_s[_offering_hash].update_block_number = uint32(block.number);

      emit LogOfferingPopedUp(msg.sender,
                              _offering_hash,
                              offering.min_deposit,
                              offering.current_supply,
                              _source_type, _source
                             ); // test E8
    }

    function extractSignature(
        address _address,
        uint32 _open_block_number,
        bytes32 _offering_hash,
        uint64 _balance,
        bytes memory _msg_sig,
        bool _type)
        public
        view
        returns (address)
    {

        bytes32 message_hash =
        keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",
            keccak256(abi.encodePacked(
                _type ? 'Privatix: sender balance proof signature' : 'Privatix: receiver closing signature',
                _address,
                _open_block_number,
                _offering_hash,
                _balance,
                address(this)
            ))
        ));

        address signer = ECVerify.ecverify(message_hash, _msg_sig);
        return signer;
    }

    function getKey(
        address _client_address,
        address _agent_address,
        uint32 _open_block_number,
        bytes32 _offering_hash)
        public
        pure
        returns (bytes32 data)
    {

        return keccak256(abi.encodePacked(_client_address, _agent_address, _open_block_number, _offering_hash));
    }


     function increaseOfferingSupply(address _agent_address, bytes32 _offering_hash)
      private
      returns (bool)
    {

      require(service_offering_s[_offering_hash].current_supply < service_offering_s[_offering_hash].max_supply);
      require(service_offering_s[_offering_hash].agent_address == _agent_address);
      if(service_offering_s[_offering_hash].update_block_number == 0) return true;

      service_offering_s[_offering_hash].current_supply = service_offering_s[_offering_hash].current_supply+1;

      return true;
    }


    function decreaseOfferingSupply(address _agent_address, bytes32 _offering_hash)
     private
   {

     require(service_offering_s[_offering_hash].update_block_number > 0);
     require(service_offering_s[_offering_hash].agent_address == _agent_address);
     require(service_offering_s[_offering_hash].current_supply > 0); // test I5

     service_offering_s[_offering_hash].current_supply = service_offering_s[_offering_hash].current_supply-1;

   }

    function createChannelPrivate(address _client_address,
                                  address _agent_address,
                                  bytes32 _offering_hash,
                                  uint64 _deposit) private {


        require(_deposit <= channel_deposit_bugbounty_limit);

        uint32 open_block_number = uint32(block.number);

        bytes32 key = getKey(_client_address, _agent_address, open_block_number, _offering_hash);

        require(channels[key].deposit == 0);
        require(channels[key].open_block_number == 0);
        require(closing_requests[key].settle_block_number == 0);

        channels[key] = Channel({deposit: _deposit, open_block_number: open_block_number});
    }

    function updateInternalBalanceStructs(
        address _client_address,
        address _agent_address,
        uint32 _open_block_number,
        bytes32 _offering_hash,
        uint64 _added_deposit)
        private
    {

        require(_added_deposit > 0);
        require(_open_block_number > 0);

        bytes32 key = getKey(_client_address, _agent_address, _open_block_number, _offering_hash);

        require(channels[key].deposit > 0);
        require(closing_requests[key].settle_block_number == 0);
        require(channels[key].deposit + _added_deposit <= channel_deposit_bugbounty_limit);

        channels[key].deposit += _added_deposit;
        assert(channels[key].deposit > _added_deposit);

        emit LogChannelToppedUp(_agent_address, _client_address, _offering_hash, _open_block_number, _added_deposit); // test E2
    }

    function settleChannel(
        address _client_address,
        address _agent_address,
        uint32 _open_block_number,
        bytes32 _offering_hash,
        uint64 _balance)
        private
    {

        bytes32 key = getKey(_client_address, _agent_address, _open_block_number, _offering_hash);
        Channel memory channel = channels[key];

        require(channel.open_block_number > 0);
        require(_balance <= channel.deposit);

        delete channels[key];
        delete closing_requests[key];

        require(increaseOfferingSupply(_agent_address, _offering_hash));
        uint64 fee = 0;
        if(network_fee > 0) {
            fee = (_balance/100000)*network_fee; // it's safe because network_fee can't be more than 10000
            internal_balances[network_fee_address] = internal_balances[network_fee_address].add(fee);
            _balance -= fee;
        }

        internal_balances[_agent_address] = internal_balances[_agent_address].add(_balance);

        internal_balances[_client_address] = internal_balances[_client_address].add(channel.deposit - _balance - fee); // I4 test

    }


    function addressHasCode(address _contract) private view returns (bool) {

        uint size;
        assembly {
            size := extcodesize(_contract)
        }

        return size > 0;
    }
}
pragma solidity 0.5.8;

contract Migrations {

  address public owner;
  uint public last_completed_migration;

  modifier restricted() {

    if (msg.sender == owner) _;
  }

  constructor() public {
    owner = msg.sender;
  }

  function setCompleted(uint completed) public restricted {

    last_completed_migration = completed;
  }

  function upgrade(address new_address) public restricted {

    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
pragma solidity 0.5.8;


contract MultiOwners {


    event AccessGrant(address indexed owner);
    event AccessRevoke(address indexed owner);
    
    mapping(address => bool) owners;

    constructor() public {
        owners[msg.sender] = true;
    }

    modifier onlyOwner() { 

        require(owners[msg.sender] == true);
        _; 
    }

    function isOwner() view public returns (bool) {

        return owners[msg.sender] ? true : false;
    }

    function checkOwner(address maybe_owner) view public returns (bool) {

        return owners[maybe_owner] ? true : false;
    }


    function grant(address _owner) public onlyOwner {

        owners[_owner] = true;
        emit AccessGrant(_owner);
    }

    function revoke(address _owner) public onlyOwner {

        require(msg.sender != _owner);
        owners[_owner] = false;
        emit AccessRevoke(_owner);
    }
}
