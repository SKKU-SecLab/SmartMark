
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}/**
Copyright 2019 PoolTogether LLC

This file is part of PoolTogether.

PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.

PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.8.0 <0.9.0;

library UniformRandomNumber {

  function uniform(uint256 _entropy, uint256 _upperBound) internal pure returns (uint256) {

    require(_upperBound > 0, "UniformRand/min-bound");
    uint256 min = _upperBound % (~_upperBound + 1);
    uint256 random = _entropy;
    while (true) {
      if (random >= min) {
        break;
      }
      random = uint256(keccak256(abi.encodePacked(random)));
    }
    return random % _upperBound;
  }
}/**
 *  @reviewers: [@clesaege, @unknownunknown1, @ferittuncer]
 *  @auditors: []
 *  @bounties: [<14 days 10 ETH max payout>]
 *  @deployments: []
 */

pragma solidity >=0.8.0 <0.9.0;

library SortitionSumTreeFactory {


    struct SortitionSumTree {
        uint K; // The maximum number of childs per node.
        uint[] stack;
        uint[] nodes;
        mapping(bytes32 => uint) IDsToNodeIndexes;
        mapping(uint => bytes32) nodeIndexesToIDs;
    }


    struct SortitionSumTrees {
        mapping(bytes32 => SortitionSumTree) sortitionSumTrees;
    }


    function createTree(SortitionSumTrees storage self, bytes32 _key, uint _K) internal {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        require(tree.K == 0, "Tree already exists.");
        require(_K > 1, "K must be greater than one.");
        tree.K = _K;
        tree.stack = new uint[](0);
        tree.nodes = new uint[](0);
        tree.nodes.push(0);
    }

    function set(SortitionSumTrees storage self, bytes32 _key, uint _value, bytes32 _ID) internal {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = tree.IDsToNodeIndexes[_ID];

        if (treeIndex == 0) { // No existing node.
            if (_value != 0) { // Non zero value.
                if (tree.stack.length == 0) { // No vacant spots.
                    treeIndex = tree.nodes.length;
                    tree.nodes.push(_value);

                    if (treeIndex != 1 && (treeIndex - 1) % tree.K == 0) { // Is first child.
                        uint parentIndex = treeIndex / tree.K;
                        bytes32 parentID = tree.nodeIndexesToIDs[parentIndex];
                        uint newIndex = treeIndex + 1;
                        tree.nodes.push(tree.nodes[parentIndex]);
                        delete tree.nodeIndexesToIDs[parentIndex];
                        tree.IDsToNodeIndexes[parentID] = newIndex;
                        tree.nodeIndexesToIDs[newIndex] = parentID;
                    }
                } else { // Some vacant spot.
                    treeIndex = tree.stack[tree.stack.length - 1];
                    tree.stack.pop();
                    tree.nodes[treeIndex] = _value;
                }

                tree.IDsToNodeIndexes[_ID] = treeIndex;
                tree.nodeIndexesToIDs[treeIndex] = _ID;

                updateParents(self, _key, treeIndex, true, _value);
            }
        } else { // Existing node.
            if (_value == 0) { // Zero value.
                uint value = tree.nodes[treeIndex];
                tree.nodes[treeIndex] = 0;

                tree.stack.push(treeIndex);

                delete tree.IDsToNodeIndexes[_ID];
                delete tree.nodeIndexesToIDs[treeIndex];

                updateParents(self, _key, treeIndex, false, value);
            } else if (_value != tree.nodes[treeIndex]) { // New, non zero value.
                bool plusOrMinus = tree.nodes[treeIndex] <= _value;
                uint plusOrMinusValue = plusOrMinus ? _value - tree.nodes[treeIndex] : tree.nodes[treeIndex] - _value;
                tree.nodes[treeIndex] = _value;

                updateParents(self, _key, treeIndex, plusOrMinus, plusOrMinusValue);
            }
        }
    }


    function queryLeafs(
        SortitionSumTrees storage self,
        bytes32 _key,
        uint _cursor,
        uint _count
    ) internal view returns(uint startIndex, uint[] memory values, bool hasMore) {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];

        for (uint i = 0; i < tree.nodes.length; i++) {
            if ((tree.K * i) + 1 >= tree.nodes.length) {
                startIndex = i;
                break;
            }
        }

        uint loopStartIndex = startIndex + _cursor;
        values = new uint[](loopStartIndex + _count > tree.nodes.length ? tree.nodes.length - loopStartIndex : _count);
        uint valuesIndex = 0;
        for (uint j = loopStartIndex; j < tree.nodes.length; j++) {
            if (valuesIndex < _count) {
                values[valuesIndex] = tree.nodes[j];
                valuesIndex++;
            } else {
                hasMore = true;
                break;
            }
        }
    }

    function draw(SortitionSumTrees storage self, bytes32 _key, uint _drawnNumber) internal view returns(bytes32 ID) {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = 0;
        uint currentDrawnNumber = _drawnNumber % tree.nodes[0];

        while ((tree.K * treeIndex) + 1 < tree.nodes.length)  // While it still has children.
            for (uint i = 1; i <= tree.K; i++) { // Loop over children.
                uint nodeIndex = (tree.K * treeIndex) + i;
                uint nodeValue = tree.nodes[nodeIndex];

                if (currentDrawnNumber >= nodeValue) currentDrawnNumber -= nodeValue; // Go to the next child.
                else { // Pick this child.
                    treeIndex = nodeIndex;
                    break;
                }
            }
        
        ID = tree.nodeIndexesToIDs[treeIndex];
    }

    function stakeOf(SortitionSumTrees storage self, bytes32 _key, bytes32 _ID) internal view returns(uint value) {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = tree.IDsToNodeIndexes[_ID];

        if (treeIndex == 0) value = 0;
        else value = tree.nodes[treeIndex];
    }

    function total(SortitionSumTrees storage self, bytes32 _key) internal view returns (uint) {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        if (tree.nodes.length == 0) {
            return 0;
        } else {
            return tree.nodes[0];
        }
    }


    function updateParents(SortitionSumTrees storage self, bytes32 _key, uint _treeIndex, bool _plusOrMinus, uint _value) private {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];

        uint parentIndex = _treeIndex;
        while (parentIndex != 0) {
            parentIndex = (parentIndex - 1) / tree.K;
            tree.nodes[parentIndex] = _plusOrMinus ? tree.nodes[parentIndex] + _value : tree.nodes[parentIndex] - _value;
        }
    }
}pragma solidity >=0.8.0 <0.9.0;

interface IGVRF {


    function getRandomNumber() external returns (bytes32 requestId);


    function getContractLinkBalance() external view returns (uint);


    function getContractBalance() external view returns (uint);

}pragma solidity >=0.8.0 <0.9.0;





contract RaffleContract is Ownable {

    using SortitionSumTreeFactory for SortitionSumTreeFactory.SortitionSumTrees;

    bytes32 private constant TREE_KEY = keccak256("Gamedrop/Raffle");
    uint256 private constant MAX_TREE_LEAVES = 5; //chose this constant to balance cost of read vs write. Could be optimized with data
    SortitionSumTreeFactory.SortitionSumTrees internal sortition_sum_trees;

    struct NFT {
        IERC721 nft_contract;
        uint256 token_id;
    }
    struct NextEpochBalanceUpdate {
        address user;
        uint256 new_balance;
    }

    IERC20 public gaming_test_token;
    IGVRF public gamedrop_vrf_contract;

    uint256 total_token_entered;
    uint256 total_time_weighted_balance;
    uint256 last_raffle_time;
    bytes32 current_random_request_id;

    address public most_recent_raffle_winner;
    NFT public most_recent_prize;

    NFT[] public vaultedNFTs;
    mapping(IERC721 => mapping(uint256 => bool)) is_NFT_in_vault;
    mapping(IERC721 => mapping(uint256 => uint256)) index_of_nft_in_array;

    address[] next_epoch_balance_instructions;
    mapping(address => bool) is_user_already_in_next_epoch_array;
    mapping(address => uint256) user_to_old_balance;
    mapping(address => uint256) user_to_new_balance;

    mapping(address => uint256) public raw_balances;

    mapping(address => bool) private _address_whitelist;
    mapping(IERC721 => bool) private _nft_whitelist;

    event depositMade(
        address sender,
        uint256 amount,
        uint256 total_token_entered
    );
    event withdrawMade(
        address sender,
        uint256 amount,
        uint256 total_token_entered
    );
    event NFTVaulted(address sender, IERC721 nft_contract, uint256 token_id);
    event AddressWhitelist(address whitelist_address);
    event NFTWhitelist(IERC721 nft_address);
    event NFTsent(
        address nft_recipient,
        IERC721 nft_contract_address,
        uint256 token_id
    );
    event raffleInitiated(uint256 time, bytes32 request_id, address initiator);
    event raffleCompleted(uint256 time, address winner, NFT prize);

    constructor(address _deposit_token) {
        last_raffle_time = block.timestamp;

        total_token_entered = 0;

        gaming_test_token = IERC20(_deposit_token);

        sortition_sum_trees.createTree(TREE_KEY, MAX_TREE_LEAVES);
    }

    modifier addRaffleBalance(uint256 amount) {

        uint256 time_between_raffles = 604800;
        uint256 time_until_next_raffle = (time_between_raffles -
            (block.timestamp - last_raffle_time));
        uint256 updated_balance = time_until_next_raffle * amount;

        raw_balances[msg.sender] += amount;

        sortition_sum_trees.set(
            TREE_KEY,
            updated_balance,
            bytes32(uint256(uint160(msg.sender)))
        );

        _;

        uint256 next_balance = raw_balances[msg.sender] * time_between_raffles;

        user_to_old_balance[msg.sender] = updated_balance;
        user_to_new_balance[msg.sender] = next_balance;

        if (is_user_already_in_next_epoch_array[msg.sender] == false) {
            next_epoch_balance_instructions.push(msg.sender);
        }

        total_time_weighted_balance += time_until_next_raffle * amount;
    }

    modifier subtractRaffleBalance(uint256 amount) {

        uint256 time_between_raffles = 604800;
        uint256 time_until_next_raffle = (time_between_raffles -
            (block.timestamp - last_raffle_time));
        uint256 updated_balance = time_until_next_raffle * amount;

        raw_balances[msg.sender] -= amount;

        sortition_sum_trees.set(
            TREE_KEY,
            updated_balance,
            bytes32(uint256(uint160(msg.sender)))
        );

        _;

        uint256 next_balance = raw_balances[msg.sender] * time_between_raffles;

        user_to_old_balance[msg.sender] = updated_balance;
        user_to_new_balance[msg.sender] = next_balance;

        if (is_user_already_in_next_epoch_array[msg.sender] == false) {
            next_epoch_balance_instructions.push(msg.sender);
        }

        total_time_weighted_balance -= time_until_next_raffle * amount;
    }

    function Deposit(uint256 amount) public payable addRaffleBalance(amount) {

        require(amount > 0, "Cannot stake 0");
        require(gaming_test_token.balanceOf(msg.sender) >= amount);

        bool sent = gaming_test_token.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        require(sent, "Failed to transfer tokens from user to vendor");

        total_token_entered += amount;

        emit depositMade(msg.sender, amount, total_token_entered);
    }

    function Withdraw(uint256 amount)
        public
        payable
        subtractRaffleBalance(amount)
    {

        require(amount > 0, "Cannot withdraw 0");
        require(
            raw_balances[msg.sender] >= amount,
            "Cannot withdraw more than you own"
        );

        bool withdrawn = gaming_test_token.transfer(msg.sender, amount);
        require(withdrawn, "Failed to withdraw tokens from contract to user");

        total_token_entered -= amount;

        emit withdrawMade(msg.sender, amount, total_token_entered);
    }

    function vaultNFT(IERC721 nft_contract_address, uint256 token_id) public {

        require(
            _address_whitelist[msg.sender],
            "Address not whitelisted to contribute NFTS, to whitelist your address reach out to Joe"
        );
        require(
            _nft_whitelist[nft_contract_address],
            "This NFT type is not whitelisted currently, to add your NFT reach out to Joe"
        );

        IERC721 nft_contract = nft_contract_address;
        nft_contract.transferFrom(msg.sender, address(this), token_id);

        NFT memory new_nft = NFT({
            nft_contract: nft_contract,
            token_id: token_id
        });
        vaultedNFTs.push(new_nft);

        uint256 index = vaultedNFTs.length - 1;
        is_NFT_in_vault[nft_contract][token_id] = true;
        index_of_nft_in_array[nft_contract][token_id] = index;

        emit NFTVaulted(msg.sender, nft_contract_address, token_id);
    }

    modifier isWinner() {

        require(msg.sender == most_recent_raffle_winner);
        _;
    }

    modifier prizeUnclaimed() {

        require(
            is_NFT_in_vault[most_recent_prize.nft_contract][
                most_recent_prize.token_id
            ],
            "prize already claimed"
        );
        _;
    }

    modifier removeNFTFromArray() {

        _;
        uint256 index = index_of_nft_in_array[most_recent_prize.nft_contract][
            most_recent_prize.token_id
        ];
        uint256 last_index = vaultedNFTs.length - 1;

        vaultedNFTs[index] = vaultedNFTs[last_index];
        vaultedNFTs.pop();
        is_NFT_in_vault[most_recent_prize.nft_contract][
            most_recent_prize.token_id
        ] = false;
    }

    function claimPrize() external isWinner prizeUnclaimed removeNFTFromArray {

        _sendNFTFromVault(
            most_recent_prize.nft_contract,
            most_recent_prize.token_id,
            msg.sender
        );
    }

    function _sendNFTFromVault(
        IERC721 nft_contract_address,
        uint256 token_id,
        address nft_recipient
    ) internal {

        IERC721 nft_contract = nft_contract_address;
        nft_contract.approve(nft_recipient, token_id);
        nft_contract.transferFrom(address(this), nft_recipient, token_id);

        emit NFTsent(nft_recipient, nft_contract_address, token_id);
    }

    function initiateRaffle() external returns (bytes32) {

        require(vaultedNFTs.length > 0, "no NFTs to raffle");

        current_random_request_id = gamedrop_vrf_contract.getRandomNumber();

        emit raffleInitiated(
            block.timestamp,
            current_random_request_id,
            msg.sender
        );

        return current_random_request_id;
    }

    modifier _updateBalancesAfterRaffle() {

        _;

        uint256 x;

        for (x = 0; x < next_epoch_balance_instructions.length; x++) {
            address user = next_epoch_balance_instructions[x];
            uint256 next_balance = user_to_new_balance[user];

            sortition_sum_trees.set(
                TREE_KEY,
                next_balance,
                bytes32(uint256(uint160(user)))
            );

            uint256 old_balance = user_to_old_balance[user];
            total_time_weighted_balance += next_balance - old_balance;
        }

        delete next_epoch_balance_instructions;
    }

    function _chooseWinner(uint256 random_number) internal returns (address) {

        uint256 bound = total_time_weighted_balance;
        address selected;

        if (bound == 0) {
            selected = address(0);
        } else {
            uint256 number = UniformRandomNumber.uniform(random_number, bound);
            selected = address(
                (uint160(uint256(sortition_sum_trees.draw(TREE_KEY, number))))
            );
        }
        return selected;
    }

    function _chooseNFT(uint256 random_number) internal returns (NFT memory) {

        uint256 bound = vaultedNFTs.length;
        uint256 index_of_nft;

        index_of_nft = UniformRandomNumber.uniform(random_number, bound);

        return vaultedNFTs[index_of_nft];
    }

    function completeRaffle(uint256 random_number)
        external
        _updateBalancesAfterRaffle
    {

        most_recent_raffle_winner = _chooseWinner(random_number);
        most_recent_prize = _chooseNFT(random_number);

        emit raffleCompleted(
            block.timestamp,
            most_recent_raffle_winner,
            most_recent_prize
        );
    }

    function updateGamedropVRFContract(IGVRF new_vrf_contract)
        public
        onlyOwner
    {

        gamedrop_vrf_contract = new_vrf_contract;
    }

    function addAddressToWhitelist(address whitelist_address) public onlyOwner {

        _address_whitelist[whitelist_address] = true;

        emit AddressWhitelist(whitelist_address);
    }

    function addNFTToWhitelist(IERC721 nft_whitelist_address) public {

        require(msg.sender == owner(), "sender not owner");
        _nft_whitelist[nft_whitelist_address] = true;

        emit NFTWhitelist(nft_whitelist_address);
    }

    function view_raw_balance(address wallet_address)
        public
        view
        returns (uint256)
    {

        return raw_balances[wallet_address];
    }

    function is_address_whitelisted(address wallet_address)
        public
        view
        returns (bool)
    {

        return _address_whitelist[wallet_address];
    }

    function is_nft_whitelisted(IERC721 nft_contract)
        public
        view
        returns (bool)
    {

        return _nft_whitelist[nft_contract];
    }

    function view_odds_of_winning(address user) public view returns (uint256) {

        return
            sortition_sum_trees.stakeOf(
                TREE_KEY,
                bytes32(uint256(uint160(user)))
            );
    }

    function get_total_number_of_NFTS() public view returns (uint256) {

        return vaultedNFTs.length;
    }

    function check_if_NFT_in_vault(IERC721 nft_contract, uint256 token_id)
        public
        view
        returns (bool)
    {

        return is_NFT_in_vault[nft_contract][token_id];
    }
}