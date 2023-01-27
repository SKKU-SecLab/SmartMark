

pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.16;


library utilities {


    using SafeMath for uint;


    function sort_array(uint[] memory arr) internal pure returns (uint[] memory) {

        uint l = arr.length;
        for (uint i = 0; i < l; i++) {
            for (uint j = i + 1; j < l; j++) {
                if (arr[i] > arr[j]) {
                    uint temp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = temp;
                }
            }
        }
        return arr;
    }

    function stringToUint(string memory s) internal pure returns (uint) {

        bytes memory b = bytes(s);
        uint i;
        uint result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }

    function uintToString(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function substrReversed(string memory str, uint startIndex, uint endIndex) internal pure returns (string memory) {

        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        uint j = 0;
        for (uint i = endIndex - 1; i >= startIndex; i--) {
            result[j] = strBytes[i];
            j += 1;
        }
        return string(result);
    }

}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.16;
// pragma experimental ABIEncoderV2;












contract Whackers is Ownable {


    using SafeMath for uint;

    IERC20 internal whackd;

    uint public ante;          // the amount of deposit required for active round, zero if new round.
    uint public start;         // annotate the date of the first ante
    uint public index;         // Countdown to having ten entrants
    uint public minimumAnte;   // setting for minimum deposit amount
    bool public uniqueWallet;  // setting for whether a single address may register multiple times in a round
    bool internal settling;    // used during settling process
    bool public suspend;       // owner can suspend the contract from accepting deposits

    constructor(IERC20 _whackd) public {
        index = 10;
        ante = 0;
        minimumAnte = 0;
        settling = false;
        uniqueWallet = true;
        whackd = _whackd;
        suspend = false;
    }

    event ReceivedTokens(address from, uint value, address token, bytes extraData);

    Player[10] players;
    address[5] winners;

    struct Player {
        address payable addr;
        string identifier;
    }

    modifier validDeposit(address from, uint amount) {

        if (ante > 0) {
            require(amount == ante, "Ante is set: Must send exact amount");
        } else {
            require(amount > 0, "Must send a deposit, Ante is open.");
        }
        if (uniqueWallet){
            for (uint i = 0; i < players.length; i++) {
                require(from != players[i].addr, "Deposit must be from a unique wallet.");
            }
        }
        require(settling == false, "Cannot accept a deposit during settling process, try again in a moment.");
        _;
    }

    function receiveApproval(address payable from, uint256 amount, address token, bytes memory extraData) public validDeposit(from, amount){


        if (!suspend) {
            require(IERC20(token) == whackd, "This contract only accepts WHACKD.");
            require(amount > minimumAnte, "Deposit must be above minimum ante.");
            require(IERC20(token).transferFrom(from, address(this), amount), "Must Approve transaction first.");

            emit ReceivedTokens(from, amount, token, extraData);

            string memory s = utilities.uintToString(block.timestamp.mul(index));
            string memory id = utilities.substrReversed(s, 8, 10);

            Player memory newPlayer = Player({addr : from, identifier : id});
            index -= 1;
            players[index] = newPlayer;

            if (ante == 0) {
                ante = amount;
                start = now; // overwrite last round start time
            }
            if (index == 0) {
                settle();
            }
        } else {
            revert();
        }
    }

    function settle() internal {


        settling = true;
        uint kitty = 0;
        uint[] memory list = sortById();

        kitty = whackd.balanceOf(address(this));
        payouts(list, kitty);

        cleanUp();
    }

    function payouts(uint[] memory list, uint kitty) public payable {


        if (settling) {
            Player memory player2;
            Player memory player3;
            Player memory player4;
            Player memory player5;

            for (uint i = 0; i < players.length; i++) {
                if (utilities.stringToUint(players[i].identifier) == list[1]) {
                    player2 = players[i];
                    list[1] = 1000; // clear channel 1 from further winners
                }
                else if (utilities.stringToUint(players[i].identifier) == list[2]) {
                    player3 = players[i];
                    list[2] = 1000;
                }
                else if (utilities.stringToUint(players[i].identifier) == list[3]) {
                    player4 = players[i];
                    list[3] = 1000;
                }
                else if (utilities.stringToUint(players[i].identifier) == list[4]) {
                    player5 = players[i];
                    list[4] = 1000;
                }
            }

            uint payout = kitty.div(7);
            uint house = payout.div(4);

            require(whackd.transfer(player2.addr, payout));
            require(whackd.transfer(player3.addr, payout));
            require(whackd.transfer(player4.addr, payout));
            require(whackd.transfer(player5.addr, payout));
            require(whackd.transfer(owner(), house));

            kitty = kitty.sub(payout.mul(4));
            kitty = kitty.sub(house);

            winners[1] = player2.addr;
            winners[2] = player3.addr;
            winners[3] = player4.addr;
            winners[4] = player5.addr;

            uint kitty2 = whackd.balanceOf(address(this)); // refresh balance

            Player memory player;
            for (uint i = 0; i < players.length; i++) {
                if (utilities.stringToUint(players[i].identifier) == list[0]) {
                    for (uint j = 0; j < 4; j++) {
                        if (winners[j] == players[i].addr){
                        } else {
                            player = players[i];
                            break;
                        }
                    }
                }
            }

            winners[0] = player.addr;
            require(whackd.transfer(player.addr, kitty2));

        } else {
            revert('Cannot call function externally');
        }
    }


    function sortById() internal view returns (uint[] memory){

        uint[] memory identifiers = new uint[](players.length);
        for (uint i = 0; i < players.length; i++) {
            identifiers[i] = utilities.stringToUint(players[i].identifier);
        }
        return utilities.sort_array(identifiers);
    }

    function cleanUp() internal {

        for (uint i = 0; i < 10; i++) {
            delete players[i];
        }
        index = 10;
        ante = 0;
        settling = false;
    }

    function forceRound(IERC20 token, uint256 amount) external payable validDeposit(msg.sender, amount){

        if (!suspend) {
            require(token == whackd, "This contract only accepts WHACKD.");
            require(amount > minimumAnte, "Deposit must be above minimum ante.");
            require(token.transferFrom(msg.sender, address(this), amount));

            if (now > start + 7 days) {

                string memory s = utilities.uintToString(block.timestamp.mul(index));
                string memory id = utilities.substrReversed(s, 8, 10);
                Player memory newPlayer = Player({addr : msg.sender, identifier : id});
                index -= 1;
                players[index] = newPlayer;

                uint count = index;
                for (uint i = count; i > 0; i--) {
                    index -= 1;
                    players[index] = newPlayer;
                }

                settle();
            }
        } else {
            revert();
        }
    }

    function oldRound() external view returns (bool){

        if (now > start + 7 days) {
          return true;
        }
        return false;
    }

    function currentPlayers(uint id) external view returns (address){

        return players[id].addr;
    }

    function lastRound(uint id) external view returns (address){

        return winners[id];
    }

    function refundAll() external payable onlyOwner {


        settling = true;
        uint divisor = 10 - index;
        uint kitty = whackd.balanceOf(address(this));
        uint payout = kitty.div(divisor);
        uint count = 0;
        for (uint i = 10; i > (10 - divisor); i--) {
            require(whackd.transfer(players[i - 1].addr, payout));
            count += 1;
        }
        cleanUp();
    }

    function setMinimumAnte(uint minAnte) external onlyOwner {

        require(index == 10, "Currently in a round.");
        minimumAnte = minAnte;
    }

    function toggleUniqueWallet() external onlyOwner {

       uniqueWallet = !uniqueWallet;
    }

    function() external payable {
        revert();
    }

    function toggleSuspend() external onlyOwner {

        if (index == 10){
            suspend = !suspend;
        }
    }

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return IERC20(tokenAddress).transfer(owner(), tokens);
    }
}