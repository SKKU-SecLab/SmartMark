
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {

	  address private _owner = 0xe39b8617D571CEe5e75e1EC6B2bb40DdC8CF6Fa3; // Votium multi-sig address

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

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
}// MIT

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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

pragma solidity ^0.8.0;


interface Swap {

  function SwapStake(uint256, uint256, uint8) external; // in, out, method

}
interface Stash {

  function lockCRV(uint256) external;

}


contract SpaceAuction is Ownable {


  using SafeERC20 for IERC20;


  Swap public swapper;    // interface with sushi/curve swap contract
  address public stash;   // interface with merkle stash contract

  struct Bids {
    address owner;        // bidder
    uint256 maxPerVote;   // max paid per 1 vote
    uint256 maxTotal;     // max paid total
    bool invalid;         // becomes invalid if at the end of the auction, the bidder's snapshot vote does not match their registered hash
  }

  struct ProposalData {
    uint256 deadline;     // set to 2 hours before snapshot voting ends
    uint256 winningBid;   // not set until proposal status is at least 1. Is not final until 2
    uint256 power;        // number of votes cast on behalf of the winner. Is not final until 2
    uint8 status;
    Bids[] bids; // array of 'Bids' struct found above
  }

  struct Bidders {
    bytes32 msgHash;
    uint256 balance;
    uint256 bidId;
  }

  mapping(bytes32 => mapping(address => Bidders)) public bidder;        // maps proposal id + address to Bidders
  mapping(bytes32 => ProposalData) public proposal;                     // maps proposal id to ProposalData
  bytes32[] public proposals;                                           // public registry of proposal ids

  mapping(address => bool) public approvedTeam;                         // for team functions that do not require multi-sig security

  address public platform = 0xe39b8617D571CEe5e75e1EC6B2bb40DdC8CF6Fa3; // Team multi-sig address

  uint256 public slashFee = 300;                                        // 3% initial slash fee
  uint256 public constant DENOMINATOR = 10000;                          // denominates Ratio as % with 2 decimals (100 = 1%)

  mapping(bytes32 => bool) public winningHashes;                        // tells vote proxy contract if a vote is valid

  IERC20 public CRV = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);


  constructor(address _swapper, address _stash) {
    swapper = Swap(_swapper);        // sets swap contract address to interface
    stash = _stash;                  // sets merkle stash address without interface
    approvedTeam[msg.sender] = true; // adds deployer address to approved team functions
  }


  function updateSwapper(address _swapper) public onlyOwner {

    swapper = Swap(_swapper);
  }
  function updateStash(address _stash) public onlyOwner {

    stash = _stash;
  }
  function setFees(uint256 _slash) public onlyOwner {

    require(_slash < 1000, "!<1000");  // Allowable range of 0 to 10% for slash
    slashFee = _slash;
  }
  function modifyTeam(address _member, bool _approval) public onlyOwner {

    approvedTeam[_member] = _approval;
  }
  function emergencyValidation(bytes32 _hash) public onlyOwner {

    winningHashes[_hash] = true;
  }

  function initiateAuction(bytes32 _proposal, uint256 _deadline) public onlyTeam {

    require(proposal[_proposal].deadline == 0, "exists");
    proposal[_proposal].deadline = _deadline;
    proposals.push(_proposal);
  }

  function selectWinner(bytes32 _proposal, uint256 _votes) public onlyTeam {

    require(proposal[_proposal].deadline < block.timestamp, "Auction has not ended");
    require(proposal[_proposal].status < 2, "!<2");
    (uint256 w, bool hasWinner) = winnerIf(_proposal, _votes);
    require(hasWinner == true, "No qualifying bids");
    proposal[_proposal].winningBid = w;
    proposal[_proposal].power = _votes;
    proposal[_proposal].status = 1;
  }

  function confirmWinner(bytes32 _proposal) public onlyTeam {

    require(proposal[_proposal].status == 1, "!1");
    bytes32 _hash = bidder[_proposal][proposal[_proposal].bids[proposal[_proposal].winningBid].owner].msgHash;
    winningHashes[_hash] = true;
    proposal[_proposal].status = 2;
  }

  function invalidateWinner(bytes32 _proposal, bool _slash) public onlyTeam {

    require(proposal[_proposal].status == 1, "!1"); // Can only invalidate if the winner has not been confirmed
    uint256 w = proposal[_proposal].winningBid;
    require(proposal[_proposal].bids[w].invalid == false, "already invalidated"); // prevents double slashing
    proposal[_proposal].bids[w].invalid = true;
    if(_slash == true) {
      uint256 slashed = bidder[_proposal][proposal[_proposal].bids[w].owner].balance*slashFee/DENOMINATOR; // calculate slashed amount
      bidder[_proposal][proposal[_proposal].bids[w].owner].balance -= slashed;  // remove slashed amount from user balance
      CRV.safeTransfer(platform, slashed); // send slashed amount to platform multi-sig
    }
  }

  function finalize(bytes32 _proposal, uint256 _votes, uint256 _minOut, uint8 _method) public onlyTeam {

    require(proposal[_proposal].status == 2, "!2"); // Can only finalize if winner confirmed
    if(_votes == 0) {
      proposal[_proposal].status = 4; // finalize with no winner
    } else {
      Bids memory currentBid = proposal[_proposal].bids[proposal[_proposal].winningBid];
      uint256 paidTotal = currentBid.maxTotal;
      uint256 paidPer = paidTotal/_votes;
      if(paidPer > currentBid.maxPerVote) {
        paidPer = currentBid.maxPerVote;
        paidTotal = paidPer*_votes;
      }
      bidder[_proposal][currentBid.owner].balance -= paidTotal; // removed paid total from winner balance
      if(_minOut == 0) {
        CRV.approve(stash, paidTotal);
        Stash(stash).lockCRV(paidTotal);
      } else {
        CRV.approve(address(swapper), paidTotal);
        swapper.SwapStake(paidTotal, _minOut, _method);
      }
      proposal[_proposal].status = 3; // set status to finalized with winner
    }
  }


  function proposalsLength() public view returns (uint256) {

    return proposals.length;
  }

  function bidsInProposal(bytes32 _proposal) public view returns (uint256) {

    return proposal[_proposal].bids.length;
  }

  function viewBid(bytes32 _proposal, uint256 _bid) public view returns (Bids memory bid) {

    bid = proposal[_proposal].bids[_bid];
  }

  function isValidSignature(bytes32 _hash, bytes memory _signature) public view returns (bool) {

    return winningHashes[_hash];
  }

  function winnerIf(bytes32 _proposal, uint256 _votes) public view returns (uint256 winningId, bool hasWinner) {

    require(_votes > 0, "!>0"); // cannot calculate winner of zero votes
    uint256 paidPer;
    uint256 highest;
    for(uint256 i=0;i<proposal[_proposal].bids.length;i++) {
      if(proposal[_proposal].bids[i].invalid == false) {
        paidPer = proposal[_proposal].bids[i].maxTotal/_votes; // assume max total is paid
        if(paidPer > proposal[_proposal].bids[i].maxPerVote) { paidPer = proposal[_proposal].bids[i].maxPerVote; }
        if(paidPer > highest) {
          winningId = i;
          highest = paidPer;
        }
      }
    }
    if(highest > 0) { hasWinner = true; }
  }


  function forceNoWinner(bytes32 _proposal) public {

    require(proposal[_proposal].deadline+30 hours < block.timestamp, "<30hrs");
    require(proposal[_proposal].status < 3, "final");
    proposal[_proposal].status = 4;
  }

  function registerHash(bytes32 _proposal, bytes32 _hash) public {

    require(proposal[_proposal].deadline > block.timestamp, "expired");
    bidder[_proposal][msg.sender].msgHash = _hash;
  }

  function placeBid(bytes32 _proposal, uint256 _maxPerVote, uint256 _maxTotal) public {

    require(_maxTotal > 0, "Cannot bid 0");
    require(_maxPerVote > 0, "Cannot bid 0");
    require(proposal[_proposal].deadline > block.timestamp, "expired");
    require(bidder[_proposal][msg.sender].balance == 0, "Already bid");
    require(bidder[_proposal][msg.sender].msgHash != keccak256(""), "No hash");
    CRV.safeTransferFrom(msg.sender, address(this), _maxTotal);
    Bids memory currentEntry;
    currentEntry.owner = msg.sender;
    currentEntry.maxPerVote = _maxPerVote;
    currentEntry.maxTotal = _maxTotal;
    proposal[_proposal].bids.push(currentEntry);
    bidder[_proposal][msg.sender].bidId = proposal[_proposal].bids.length-1;
    bidder[_proposal][msg.sender].balance = _maxTotal;
  }

  function increaseBid(bytes32 _proposal, uint256 bidId, uint256 _maxPerVote, uint256 _maxTotal) public {

    require(proposal[_proposal].deadline > block.timestamp, "expired");
    require(proposal[_proposal].bids[bidId].owner == msg.sender, "!owner");
    if(_maxPerVote > proposal[_proposal].bids[bidId].maxPerVote) {
      proposal[_proposal].bids[bidId].maxPerVote = _maxPerVote;
    }
    if(_maxTotal > proposal[_proposal].bids[bidId].maxTotal) {
      uint256 increase = _maxTotal-proposal[_proposal].bids[bidId].maxTotal;
      CRV.safeTransferFrom(msg.sender, address(this), increase);
      proposal[_proposal].bids[bidId].maxTotal += increase;
      bidder[_proposal][msg.sender].balance += increase;
    }
  }

  function rollBalance(bytes32 _proposalA, bytes32 _proposalB, uint256 _maxPerVote) public {

    require(proposal[_proposalB].deadline > block.timestamp, "Invalid B"); // Can only roll into active auction
    require(proposal[_proposalA].status > 2, "Invalid A");  // Can only roll out of finalized auction
    require(bidder[_proposalB][msg.sender].balance == 0, "Already bid"); // Address cannot have two bids
    require(bidder[_proposalB][msg.sender].msgHash != keccak256(""), "No hash"); // Address must first register a vote hash
    require(_maxPerVote > 0, "bid 0"); // Cannot bid 0
    require(bidder[_proposalA][msg.sender].balance > 0, "0 balance"); // No balance to transfer

    uint256 bal = bidder[_proposalA][msg.sender].balance; // store original auction balance
    bidder[_proposalA][msg.sender].balance = 0; // set original auction balance to 0
    Bids memory currentEntry;
    currentEntry.owner = msg.sender;
    currentEntry.maxPerVote = _maxPerVote;
    currentEntry.maxTotal = bal;
    proposal[_proposalB].bids.push(currentEntry);
    bidder[_proposalB][msg.sender].balance = bal; // set user balance of new auction
  }

  function withdraw(bytes32 _proposal) public {

    require(proposal[_proposal].status > 2, "not final");
    uint256 bal = bidder[_proposal][msg.sender].balance; // store balance
    if(bal > 0) {
      bidder[_proposal][msg.sender].balance = 0; // set balance to 0
      CRV.safeTransfer(msg.sender, bal); // send stored balance to user
    }
  }


  modifier onlyTeam() {

    require(approvedTeam[msg.sender] == true, "Team only");
    _;
  }
}