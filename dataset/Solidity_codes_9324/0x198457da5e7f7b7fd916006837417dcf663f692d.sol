


pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}




pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}





pragma solidity >= 0.8.0;

abstract contract IQLF is IERC165 {
    function ifQualified (address account) virtual external view returns (bool);

    function logQualified (address account, uint256 ito_start_time) virtual external returns (bool);

    function supportsInterface(bytes4 interfaceId) virtual external override pure returns (bool) {
        return interfaceId == this.supportsInterface.selector || 
            interfaceId == (this.ifQualified.selector ^ this.logQualified.selector);
    }

    event Qualification(address account, bool qualified, uint256 blockNumber, uint256 timestamp);
}





pragma solidity >= 0.8.0;




contract HappyTokenPool {


    struct Pool {
        uint256 packed1;            // qualification_address(160) the smart contract address to verify qualification
        uint256 packed2;            // total_tokens(128) limit(128)
        uint48  unlock_time;        // unlock_time + base_time = real_time
        address creator;
        address token_address;      // the target token address
        address[] exchange_addrs;   // a list of ERC20 addresses for swapping
        uint128[] exchanged_tokens; // a list of amounts of swapped tokens
        uint128[] ratios;           // a list of swap ratios
        mapping(address => uint256) swapped_map;      // swapped amount of an address
    }

    struct Packed {
        uint256 packed1;
        uint256 packed2;
    }

    event FillSuccess (
        uint256 total,
        bytes32 id,
        address creator,
        uint256 creation_time,
        address token_address,
        string message
    );

    event SwapSuccess (
        bytes32 id,
        address swapper,
        address from_address,
        address to_address,
        uint256 from_value,
        uint256 to_value
    );

    event ClaimSuccess (
        bytes32 id,
        address claimer,
        uint256 timestamp,
        uint256 to_value,
        address token_address
    );

    event DestructSuccess (
        bytes32 id,
        address token_address,
        uint256 remaining_balance,
        uint128[] exchanged_values
    );

    event WithdrawSuccess (
        bytes32 id,
        address token_address,
        uint256 withdraw_balance
    );

    modifier creatorOnly {

        require(msg.sender == contract_creator, "Contract Creator Only");
        _;
    }

    using SafeERC20 for IERC20;
    uint32 nonce;
    uint224 base_time;                 // timestamp = base_time + delta to save gas
    address public contract_creator;
    mapping(bytes32 => Pool) pool_by_id;    // maps an id to a Pool instance
    string constant private magic = "Prince Philip, Queen Elizabeth II's husband, has died aged 99, \
    Buckingham Palace has announced. A statement issued by the palace just after midday spoke of the \
    Queen's deep sorrow following his death at Windsor Castle on Friday morning. The Duke of Edinbur";
    bytes32 private seed;
    address DEFAULT_ADDRESS = 0x0000000000000000000000000000000000000000;       // a universal address

    constructor() {
        contract_creator = msg.sender;
        seed = keccak256(abi.encodePacked(magic, block.timestamp, contract_creator));
        base_time = 1616976000;                                    // 00:00:00 03/30/2021 GMT(UTC+0)
    }

    function fill_pool (bytes32 _hash, uint256 _start, uint256 _end, string memory message,
                        address[] memory _exchange_addrs, uint128[] memory _ratios, uint256 _unlock_time,
                        address _token_addr, uint256 _total_tokens, uint256 _limit, address _qualification)
    public payable {
        nonce ++;
        require(_start < _end, "Start time should be earlier than end time.");
        require(_end < _unlock_time || _unlock_time == 0, "End time should be earlier than unlock time");
        require(_limit <= _total_tokens, "Limit needs to be less than or equal to the total supply");
        require(_total_tokens < 2 ** 128, "No more than 2^128 tokens(incluidng decimals) allowed");
        require(IERC20(_token_addr).allowance(msg.sender, address(this)) >= _total_tokens, "Insuffcient allowance");
        require(_exchange_addrs.length > 0, "Exchange token addresses need to be set");
        require(_ratios.length == 2 * _exchange_addrs.length, "Size of ratios = 2 * size of exchange_addrs");

        bytes32 _id = keccak256(abi.encodePacked(msg.sender, block.timestamp, nonce, seed));
        Pool storage pool = pool_by_id[_id];
        pool.packed1 = wrap1(_qualification, _hash, _start, _end);      // 256 bytes    detail in wrap1()
        pool.packed2 = wrap2(_total_tokens, _limit);                    // 256 bytes    detail in wrap2()
        pool.unlock_time = uint48(_unlock_time);                        // 48  bytes    unlock_time 0 -> unlocked
        pool.creator = msg.sender;                                      // 160 bytes    pool creator
        pool.exchange_addrs = _exchange_addrs;                          // 160 bytes    target token
        pool.token_address = _token_addr;                               // 160 bytes    target token address

        for (uint256 i = 0; i < _exchange_addrs.length; i++) {
            if (_exchange_addrs[i] != DEFAULT_ADDRESS) {
                require(IERC20(_exchange_addrs[i]).totalSupply() > 0, "Not a valid ERC20");
            }
            pool.exchanged_tokens.push(0); 
        }

        for (uint256 i = 0; i < _ratios.length; i+= 2) {
            uint256 divA = SafeMath.div(_ratios[i], _ratios[i+1]);      // Non-zero checked by SafteMath.div
            uint256 divB = SafeMath.div(_ratios[i+1], _ratios[i]);      // Non-zero checked by SafteMath.div
            
            if (_ratios[i] == 1) {
                require(divB == _ratios[i+1]);
            } else if (_ratios[i+1] == 1) {
                require(divA == _ratios[i]);
            } else {
                require(divA * _ratios[i+1] != _ratios[i]);
                require(divB * _ratios[i] != _ratios[i+1]);
            }
        }
        pool.ratios = _ratios;                                          // 256 * k
        IERC20(_token_addr).safeTransferFrom(msg.sender, address(this), _total_tokens);

        emit FillSuccess(_total_tokens, _id, msg.sender, block.timestamp, _token_addr, message);
    }


    function swap (bytes32 id, bytes32 verification, 
                   bytes32 validation, uint256 exchange_addr_i, uint128 input_total) 
    public payable returns (uint256 swapped) {

        Pool storage pool = pool_by_id[id];
        Packed memory packed = Packed(pool.packed1, pool.packed2);
        require (
            IQLF(
                address(
                    uint160(unbox(packed.packed1, 0, 160)))
                ).logQualified(msg.sender, uint256(unbox(packed.packed1, 200, 28) + base_time)
            ) == true, 
            "Not Qualified"
        );
        require (unbox(packed.packed1, 200, 28) + base_time < block.timestamp, "Not started.");
        require (unbox(packed.packed1, 228, 28) + base_time > block.timestamp, "Expired.");
        require (verification == keccak256(abi.encodePacked(unbox(packed.packed1, 160, 40), msg.sender)), 
                 'Wrong Password');
        require (validation == keccak256(abi.encodePacked(msg.sender)), "Validation Failed");

        uint256 total_tokens = unbox(packed.packed2, 0, 128);
        require (total_tokens > 0, "Out of Stock");

        address exchange_addr = pool.exchange_addrs[exchange_addr_i];
        uint256 ratioA = pool.ratios[exchange_addr_i*2];
        uint256 ratioB = pool.ratios[exchange_addr_i*2 + 1];
        if (exchange_addr == DEFAULT_ADDRESS) {
            require(msg.value == input_total, 'No enough ether.');
        } else {
            uint256 allowance = IERC20(exchange_addr).allowance(msg.sender, address(this));
            require(allowance >= input_total, 'No enough allowance.');
        }

        uint256 swapped_tokens;
        swapped_tokens = SafeMath.div(SafeMath.mul(input_total, ratioB), ratioA);       // 2^256=10e77 >> 10e18 * 10e18
        require(swapped_tokens > 0, "Better not draw water with a sieve");

        uint256 limit = unbox(packed.packed2, 128, 128);
        if (swapped_tokens > limit) {
            swapped_tokens = limit;
            input_total = uint128(SafeMath.div(SafeMath.mul(limit, ratioA), ratioB));           // Update input_total
        } else if (swapped_tokens > total_tokens) {
            swapped_tokens = total_tokens;
            input_total = uint128(SafeMath.div(SafeMath.mul(total_tokens, ratioA), ratioB));    // Update input_total
            if (exchange_addr == DEFAULT_ADDRESS)
                payable(msg.sender).transfer(msg.value - input_total);
        }
        require(swapped_tokens <= limit);                                                       // make sure again
        pool.exchanged_tokens[exchange_addr_i] = uint128(SafeMath.add(pool.exchanged_tokens[exchange_addr_i], 
                                                                      input_total));            // update exchanged

        require (pool.swapped_map[msg.sender] == 0, "Already swapped");

        pool.packed2 = rewriteBox(packed.packed2, 0, 128, SafeMath.sub(total_tokens, swapped_tokens));
        pool.swapped_map[msg.sender] = swapped_tokens;

        if (exchange_addr != DEFAULT_ADDRESS) {
            IERC20(exchange_addr).safeTransferFrom(msg.sender, address(this), input_total);
        }

        emit SwapSuccess(id, msg.sender, exchange_addr, pool.token_address, input_total, swapped_tokens);

        if (pool.unlock_time == 0) {
            transfer_token(pool.token_address, address(this), msg.sender, swapped_tokens);
            emit ClaimSuccess(id, msg.sender, block.timestamp, swapped_tokens, pool.token_address);
        }
            
        return swapped_tokens;
    }


    function check_availability (bytes32 id) external view 
        returns (address[] memory exchange_addrs, uint256 remaining, 
                 bool started, bool expired, bool unlocked, uint256 unlock_time,
                 uint256 swapped, uint128[] memory exchanged_tokens) {
        Pool storage pool = pool_by_id[id];
        return (
            pool.exchange_addrs,                                                // exchange_addrs 0x0 means destructed
            unbox(pool.packed2, 0, 128),                                        // remaining
            block.timestamp > unbox(pool.packed1, 200, 28) + base_time,         // started
            block.timestamp > unbox(pool.packed1, 228, 28) + base_time,         // expired
            block.timestamp > pool.unlock_time + base_time,                     // unlocked
            pool.unlock_time + base_time,                                       // unlock_time
            pool.swapped_map[msg.sender],                                       // swapped number 
            pool.exchanged_tokens                                               // exchanged tokens
        );
    }

    function claim(bytes32[] memory ito_ids) public {

        uint256 claimed_amount;
        for (uint256 i = 0; i < ito_ids.length; i++) {
            Pool storage pool = pool_by_id[ito_ids[i]];
            if (pool.unlock_time + base_time > block.timestamp)
                continue;
            claimed_amount = pool.swapped_map[msg.sender];
            if (claimed_amount == 0)
                continue;
            pool.swapped_map[msg.sender] = 0;
            transfer_token(pool.token_address, address(this), msg.sender, claimed_amount);

            emit ClaimSuccess(ito_ids[i], msg.sender, block.timestamp, claimed_amount, pool.token_address);
        }
    }

    function setUnlockTime(bytes32 id, uint256 _unlock_time) public {

        Pool storage pool = pool_by_id[id];
        require(pool.creator == msg.sender, "Pool Creator Only");
        pool.unlock_time = uint48(_unlock_time);
    }


    function destruct (bytes32 id) public {
        Pool storage pool = pool_by_id[id];
        require(msg.sender == pool.creator, "Only the pool creator can destruct.");

        uint256 expiration = unbox(pool.packed1, 228, 28) + base_time;
        uint256 remaining_tokens = unbox(pool.packed2, 0, 128);
        require(expiration <= block.timestamp || remaining_tokens == 0, "Not expired yet");

        if (remaining_tokens != 0) {
            transfer_token(pool.token_address, address(this), msg.sender, remaining_tokens);
        }
        
        for (uint256 i = 0; i < pool.exchange_addrs.length; i++) {
            if (pool.exchanged_tokens[i] > 0) {
                if (pool.exchange_addrs[i] != DEFAULT_ADDRESS)
                    transfer_token(pool.exchange_addrs[i], address(this), msg.sender, pool.exchanged_tokens[i]);
                else
                    payable(msg.sender).transfer(pool.exchanged_tokens[i]);
            }
        }
        emit DestructSuccess(id, pool.token_address, remaining_tokens, pool.exchanged_tokens);

        pool.packed1 = 0;
        pool.packed2 = 0;
        pool.creator = DEFAULT_ADDRESS;
        for (uint256 i = 0; i < pool.exchange_addrs.length; i++) {
            pool.exchange_addrs[i] = DEFAULT_ADDRESS;
            pool.exchanged_tokens[i] = 0;
            pool.ratios[i*2] = 0;
            pool.ratios[i*2+1] = 0;
        }
    }


    function withdraw (bytes32 id, uint256 addr_i) public {
        Pool storage pool = pool_by_id[id];
        require(msg.sender == pool.creator, "Only the pool creator can withdraw.");

        uint256 withdraw_balance = pool.exchanged_tokens[addr_i];
        require(withdraw_balance > 0, "None of this token left");
        uint256 expiration = unbox(pool.packed1, 228, 28) + base_time;
        uint256 remaining_tokens = unbox(pool.packed2, 0, 128);
        require(expiration <= block.timestamp || remaining_tokens == 0, "Not expired yet");
        address token_address = pool.exchange_addrs[addr_i];

        if (token_address != DEFAULT_ADDRESS)
            transfer_token(token_address, address(this), msg.sender, withdraw_balance);
        else
            payable(msg.sender).transfer(withdraw_balance);
        pool.exchanged_tokens[addr_i] = 0;
        emit WithdrawSuccess(id, token_address, withdraw_balance);
    }



    function wrap1 (address _qualification, bytes32 _hash, uint256 _start, uint256 _end) internal pure 
                    returns (uint256 packed1) {
        uint256 _packed1 = 0;
        _packed1 |= box(0, 160,  uint256(uint160(_qualification)));     // _qualification = 160 bits
        _packed1 |= box(160, 40, uint256(_hash) >> 216);                // hash = 40 bits (safe?)
        _packed1 |= box(200, 28, _start);                               // start_time = 28 bits 
        _packed1 |= box(228, 28, _end);                                 // expiration_time = 28 bits
        return _packed1;
    }


    function wrap2 (uint256 _total_tokens, uint256 _limit) internal pure returns (uint256 packed2) {
        uint256 _packed2 = 0;
        _packed2 |= box(0, 128, _total_tokens);             // total_tokens = 128 bits ~= 3.4e38
        _packed2 |= box(128, 128, _limit);                  // limit = 128 bits
        return _packed2;
    }


    function box (uint16 position, uint16 size, uint256 data) internal pure returns (uint256 boxed) {
        require(validRange(size, data), "Value out of range BOX");
        assembly {
            boxed := shl(position, data)
        }
    }


    function unbox (uint256 base, uint16 position, uint16 size) internal pure returns (uint256 unboxed) {
        require(validRange(256, base), "Value out of range UNBOX");
        assembly {
            unboxed := and(sub(shl(size, 1), 1), shr(position, base))

        }
    }


    function validRange (uint16 size, uint256 data) internal pure returns(bool ifValid) { 
        assembly {
            ifValid := or(eq(size, 256), gt(shl(size, 1), data))
        }
    }


    function rewriteBox (uint256 _box, uint16 position, uint16 size, uint256 data) 
                        internal pure returns (uint256 boxed) {
        assembly {
            boxed := or( and(_box, not(shl(position, sub(shl(size, 1), 1)))), shl(position, data))
        }
    }

   
    function transfer_token (address token_address, address sender_address,
                             address recipient_address, uint256 amount) internal {
        require(IERC20(token_address).balanceOf(sender_address) >= amount, "Balance not enough");
        IERC20(token_address).safeTransfer(recipient_address, amount);
    }
    
}