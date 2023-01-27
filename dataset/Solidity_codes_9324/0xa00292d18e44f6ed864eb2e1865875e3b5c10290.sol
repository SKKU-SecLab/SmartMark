
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

interface IERC1363Receiver {

    function onTransferReceived(
        address operator,
        address sender,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC1363 is IERC20, IERC165 {
    function transferAndCall(address recipient, uint256 amount) external returns (bool);

    function transferAndCall(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

    function transferFromAndCall(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferFromAndCall(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

    function approveAndCall(address spender, uint256 amount) external returns (bool);

    function approveAndCall(
        address spender,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}// MIT

pragma solidity ^0.8.0;

interface IERC1363Spender {
    function onApprovalReceived(
        address sender,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4);
}// MIT

pragma solidity ^0.8.0;



abstract contract ERC1363 is ERC20, IERC1363, ERC165 {
    using Address for address;

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1363).interfaceId || super.supportsInterface(interfaceId);
    }

    function transferAndCall(address recipient, uint256 amount) public virtual override returns (bool) {
        return transferAndCall(recipient, amount, "");
    }

    function transferAndCall(
        address recipient,
        uint256 amount,
        bytes memory data
    ) public virtual override returns (bool) {
        transfer(recipient, amount);
        require(_checkAndCallTransfer(_msgSender(), recipient, amount, data), "ERC1363: _checkAndCallTransfer reverts");
        return true;
    }

    function transferFromAndCall(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        return transferFromAndCall(sender, recipient, amount, "");
    }

    function transferFromAndCall(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data
    ) public virtual override returns (bool) {
        transferFrom(sender, recipient, amount);
        require(_checkAndCallTransfer(sender, recipient, amount, data), "ERC1363: _checkAndCallTransfer reverts");
        return true;
    }

    function approveAndCall(address spender, uint256 amount) public virtual override returns (bool) {
        return approveAndCall(spender, amount, "");
    }

    function approveAndCall(
        address spender,
        uint256 amount,
        bytes memory data
    ) public virtual override returns (bool) {
        approve(spender, amount);
        require(_checkAndCallApprove(spender, amount, data), "ERC1363: _checkAndCallApprove reverts");
        return true;
    }

    function _checkAndCallTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data
    ) internal virtual returns (bool) {
        if (!recipient.isContract()) {
            return false;
        }
        bytes4 retval = IERC1363Receiver(recipient).onTransferReceived(_msgSender(), sender, amount, data);
        return (retval == IERC1363Receiver(recipient).onTransferReceived.selector);
    }

    function _checkAndCallApprove(
        address spender,
        uint256 amount,
        bytes memory data
    ) internal virtual returns (bool) {
        if (!spender.isContract()) {
            return false;
        }
        bytes4 retval = IERC1363Spender(spender).onApprovalReceived(_msgSender(), amount, data);
        return (retval == IERC1363Spender(spender).onApprovalReceived.selector);
    }
}// MIT
pragma solidity 0.8.7;


interface IERC20Burnable is IERC20 {
    function burn(uint256 amount) external;

    function decimals() external view returns (uint8);
}// MIT
pragma solidity 0.8.7;


contract KickLottery is Ownable, IERC1363Receiver {
    struct LotteryRound {
        uint256 endBlock;
        address[] members;
        mapping(address => uint256) balances;
        address[] winners;
        uint256 jackpot;
        bytes32 hash;
    }
    LotteryRound[] public history;
    uint256 public roundNumber;

    IERC20Burnable public immutable token;

    uint8 public payPercent;
    uint8 public burnPercent;
    uint256 public playPeriodBlocks;
    uint256 public minBidValue;
    uint256 public constant RND_BASE = uint256(10e9); // Base of randomizer
    uint256 public maxMembers = 1000;
    uint256 public constant MAX_WINNERS = 100;

    bool public active = true;

    event BetAccepted(address account, uint256 value);
    event RoundFinalized(address[] winners, uint256 prize, uint256 roundNumber);
    event HashSaved(bytes32 hash, uint256 roundNumber);
    event PayPercentChanged(uint8 value);
    event BurnPercentChanged(uint8 value);
    event PlayPeriodBlocksChanged(uint256 value);
    event MinBidValueChanged(uint256 value);
    event MaxMembersChanged(uint256 value);

    modifier isActive() {
        require(active, "Lottery is not active");
        _;
    }

    constructor(
        address _token,
        uint256 _playPeriodBlock,
        uint8 _payPercent,
        uint8 _burnPercent,
        uint256 _minBidValue
    ) {
        token = IERC20Burnable(_token);
        playPeriodBlocks = _playPeriodBlock;
        require(_payPercent + _burnPercent <= 100, "Not valid percents");
        payPercent = _payPercent;
        burnPercent = _burnPercent;
        minBidValue = _minBidValue;
        createRound();
    }


    function createRound() private isActive {
        LotteryRound storage round = history.push();
        round.endBlock = block.number + playPeriodBlocks;
    }


    function isRoundFinished() public view returns (bool) {
        LotteryRound storage round = history[roundNumber];
        return block.number > round.endBlock;
    }

    function _join(address user, uint256 amount) private {
        LotteryRound storage round = history[roundNumber];

        require(round.members.length < maxMembers, "Too many members");

        if (round.balances[user] == 0) {
            round.members.push(user);
        }
        round.balances[user] += amount;

        emit BetAccepted(user, amount);
    }

    function join(uint256 amount) public isActive {
        require(!isRoundFinished(), "Current round is finished");
        require(amount >= minBidValue, "Amount less than minBid");

        _join(msg.sender, amount);

        token.transferFrom(msg.sender, address(this), amount);
    }

    function onTransferReceived(
        address,
        address user,
        uint256 amount,
        bytes memory
    ) public override isActive returns (bytes4) {
        require(msg.sender == address(token), "Call can do only token");
        require(!isRoundFinished(), "Current round is finished");
        require(amount >= minBidValue, "Amount less than minBid");

        _join(user, amount);

        return this.onTransferReceived.selector;
    }


    function saveRoundHash() external isActive {
        LotteryRound storage round = history[roundNumber];
        require(round.hash == bytes32(0), "Hash already saved");
        require(block.number > round.endBlock, "Current round is not finished");
        bytes32 bhash = blockhash(round.endBlock);
        require(bhash != bytes32(0), "Too far from end round block");

        round.hash = bhash;
        emit HashSaved(bhash, roundNumber);
    }

    function _checkWinners(
        LotteryRound storage round,
        bytes32 _hash,
        uint256 _jackpot
    ) private view isActive returns (address[] memory) {
        uint256 rnd = uint256(_hash);

        address[] memory winners = new address[](round.members.length);
        uint256 winnerNumber;
        for (uint256 i = 0; i < round.members.length; i++) {
            address userAddr = round.members[i];
            uint256 userRnd = (uint256(uint160(userAddr)) + rnd) % RND_BASE;
            uint256 betAmount = round.balances[round.members[i]];
            bool isWinner = userRnd < (betAmount * RND_BASE) / _jackpot;

            if (isWinner) {
                winners[winnerNumber] = userAddr;
                winnerNumber += 1;
            }
        }

        address[] memory realWinners = new address[](winnerNumber);
        if (winnerNumber > MAX_WINNERS) {
            winnerNumber = MAX_WINNERS;
        }
        for (uint256 i = 0; i < winnerNumber; i++) {
            realWinners[i] = winners[i];
        }
        return realWinners;
    }

    function checkWinners(uint256 _roundNumber, bytes32 _hash)
        external
        view
        returns (address[] memory, uint256)
    {
        require(_roundNumber == roundNumber, "Incorrect round number");
        require(_hash != bytes32(0), "Empty hash");

        LotteryRound storage round = history[_roundNumber];
        require(block.number > round.endBlock, "Round is not finished");

        if (round.hash != bytes32(0)) {
            require(_hash == round.hash, "Incorrect block hash");
        }
        bytes32 bhash = blockhash(round.endBlock);
        if (bhash != bytes32(0)) {
            require(_hash == bhash, "Incorrect block hash");
        }

        return (_checkWinners(round, _hash, jackpot()), jackpot());
    }

    function _payPrize(address[] memory winners, uint256 _jackpot)
        private
        returns (uint256)
    {
        uint256 prize = (_jackpot * payPercent) / 100 / winners.length;
        for (uint256 i = 0; i < winners.length; i++) {
            token.transfer(winners[i], prize);
        }
        token.burn((_jackpot * burnPercent) / 100);
        return prize;
    }

    function finalizeRound() external isActive {
        LotteryRound storage round = history[roundNumber];
        require(block.number > round.endBlock, "Current round is not finished");

        if (round.hash == bytes32(0)) {
            bytes32 bhash = blockhash(round.endBlock);
            require(bhash != bytes32(0), "Too far from end round block");
            round.hash = bhash;
            emit HashSaved(bhash, roundNumber);
        }

        round.jackpot = jackpot();
        address[] memory winners = _checkWinners(
            round,
            round.hash,
            round.jackpot
        );

        roundNumber++;
        createRound();

        uint256 prize;
        if (winners.length > 0) {
            round.winners = winners;
            prize = _payPrize(winners, round.jackpot);
        }

        emit RoundFinalized(winners, prize, roundNumber);
    }

    function finalizeRoundAdmin(
        uint256 _roundNumber,
        bytes32 _hash,
        address[] memory winners,
        uint256 _jackpot
    ) external onlyOwner isActive {
        require(_roundNumber == roundNumber, "Incorrect round number");
        uint256 curJackpot = jackpot();
        require(
            curJackpot / 2 <= _jackpot && _jackpot <= curJackpot,
            "Incorrect jackpot value"
        );

        LotteryRound storage round = history[roundNumber];
        require(block.number > round.endBlock, "Current round is not finished");

        bytes32 rhash = round.hash;
        if (rhash == bytes32(0)) {
            bytes32 bhash = blockhash(round.endBlock);
            if (bhash != bytes32(0)) {
                rhash = bhash;
            } else {
                rhash = _hash;
            }
            round.hash = rhash;
            emit HashSaved(rhash, roundNumber);
        }
        require(rhash == _hash, "Incorrect block hash");

        round.jackpot = _jackpot;
        uint256 prize;
        if (winners.length > 0) {
            round.winners = winners;
            prize = _payPrize(winners, _jackpot);
        }

        emit RoundFinalized(winners, prize, roundNumber);

        roundNumber++;
        createRound();
    }

    function challengeRound(uint256 _roundNumber) external isActive {
        if (!challengeRoundView(_roundNumber, bytes32(0))) {
            _kill(msg.sender);
        }
    }

    function challengeRoundView(uint256 _roundNumber, bytes32 _hash)
        public
        view
        returns (bool)
    {
        require(
            _roundNumber < roundNumber,
            "Can't challenge unfinalized round"
        );

        LotteryRound storage round = history[_roundNumber];

        if (_hash == bytes32(0)) {
            _hash = round.hash;
        }

        address[] memory realWinners = _checkWinners(
            round,
            _hash,
            round.jackpot
        );

        if (realWinners.length != round.winners.length) {
            return false;
        }

        for (uint256 i = 0; i < round.winners.length; i++) {
            if (realWinners[i] != round.winners[i]) {
                return false;
            }
        }
        return true;
    }


    function setPlayPeriodBlocks(uint256 value) external onlyOwner {
        require(value > 0, "wrong playPeriodBlock");
        playPeriodBlocks = value;
        emit PlayPeriodBlocksChanged(value);
    }

    function setPayPercent(uint8 value) external onlyOwner {
        require(value + burnPercent <= 100, "Not valid percents");
        payPercent = value;
        emit PayPercentChanged(value);
    }

    function setBurnPercent(uint8 value) external onlyOwner {
        require(value + payPercent <= 100, "Not valid percents");
        burnPercent = value;
        emit BurnPercentChanged(value);
    }

    function setMinBidValue(uint256 value) external onlyOwner {
        require(value > 0, "Not valid minBidValue");
        minBidValue = value;
        emit MinBidValueChanged(value);
    }

    function setMaxMembers(uint256 value) external onlyOwner {
        require(value > 0, "Not valid maxMemebers");
        maxMembers = value;
        emit MaxMembersChanged(value);
    }


    function roundWinners(uint256 _roundNumber)
        external
        view
        returns (address[] memory)
    {
        require(_roundNumber < history.length - 1, "Not valid round number");
        return history[_roundNumber].winners;
    }

    function roundMembers(uint256 _roundNumber)
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        require(_roundNumber < history.length, "Not valid round number");

        LotteryRound storage round = history[_roundNumber];
        uint256[] memory balances = new uint256[](round.members.length);
        for (uint256 i = 0; i < round.members.length; i++) {
            balances[i] = round.balances[round.members[i]];
        }
        return (round.members, balances);
    }

    function memberBet(uint256 _roundNumber, address member)
        external
        view
        returns (uint256)
    {
        require(_roundNumber < history.length, "Not valid round number");
        return history[_roundNumber].balances[member];
    }

    function jackpot() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function totalPlayedJackpot() external view returns (uint256) {
        uint256 total;
        for (uint256 i = 0; i < roundNumber; i++) {
            LotteryRound storage round = history[i];
            if (round.winners.length > 0) {
                total += history[i].jackpot;
            }
        }
        return total;
    }

    function memberBetHistory(address member) 
        external 
        view 
        returns (uint256[] memory, uint256[] memory, uint256[] memory) 
    {
        uint256 count;
        for (uint256 i = 0; i < roundNumber; i++) {
            LotteryRound storage round = history[i];
            if (round.balances[member] > 0) {
                count++;
            }
        }

        uint256[] memory rounds = new uint256[](count);
        uint256[] memory bets = new uint256[](count);
        uint256[] memory results = new uint256[](count);
        uint256 j;
        for (uint256 i = 0; i < roundNumber; i++) {
            LotteryRound storage round = history[i];
            if (round.balances[member] > 0) {
                rounds[j] = i;
                bets[j] = round.balances[member];
                results[j] = 0;
                for (uint256 k = 0; k < round.winners.length; k++) {
                    if (round.winners[k] == member) {
                        results[j] = (round.jackpot * payPercent) / 100 / round.winners.length;
                    }
                }
                j++;
            }
        }
        return (rounds, bets, results);
    }


    function _kill(address to) private {
        active = false;
        token.transfer(to, token.balanceOf(address(this)));
    }

    function kill(address to) external onlyOwner isActive {
        _kill(to);
    }


    function stuckFundsTransfer(
        address _token,
        address to,
        uint256 amount
    ) external onlyOwner returns (bool) {
        require(_token != address(token), "Can't withdraw lottery token");
        return IERC20(_token).transfer(to, amount);
    }
}