pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

contract TokenList {


    address private constant KingAddr = 0x5a731151d6510Eb475cc7a0072200cFfC9a3bFe5;
    address private constant KingNftAddr = 0x4c9c971fbEFc93E0900988383DC050632dEeC71E;
    address private constant QueenNftAddr = 0x3068b3313281f63536042D24562896d080844c95;
    address private constant KnightNftAddr = 0xF85C874eA05E2225982b48c93A7C7F701065D91e;
    address private constant KingWerewolfNftAddr = 0x39C8788B19b0e3CeFb3D2f38c9063b03EB1E2A5a;
    address private constant QueenVampzNftAddr = 0x440116abD7338D9ccfdc8b9b034F5D726f615f6d;
    address private constant KnightMummyNftAddr = 0x91cC2cf7B0BD7ad99C0D8FA4CdfC93C15381fb2d;
    address private constant UsdtAddr = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address private constant UsdcAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant DaiAddr = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant WethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant WbtcAddr = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address private constant NewKingAddr = 0xd2057d71fE3F5b0dc1E3e7722940E1908Fc72078;

    uint256 private constant extraTokensStartId = 33;

    enum TokenType {unknown, Erc20, Erc721, Erc1155}

    struct Token {
        address addr;
        TokenType _type;
        uint8 decimals;
    }

    Token[] private _extraTokens;

    function _listedToken(
        uint8 tokenId
    ) internal pure virtual returns(address, TokenType, uint8 decimals) {

        if (tokenId == 1) return (KingAddr, TokenType.Erc20, 18);
        if (tokenId == 2) return (UsdtAddr, TokenType.Erc20, 6);
        if (tokenId == 3) return (UsdcAddr, TokenType.Erc20, 6);
        if (tokenId == 4) return (DaiAddr, TokenType.Erc20, 18);
        if (tokenId == 5) return (WethAddr, TokenType.Erc20, 18);
        if (tokenId == 6) return (WbtcAddr, TokenType.Erc20, 8);
        if (tokenId == 7) return (NewKingAddr, TokenType.Erc20, 18);

        if (tokenId == 16) return (KingNftAddr, TokenType.Erc721, 0);
        if (tokenId == 17) return (QueenNftAddr, TokenType.Erc721, 0);
        if (tokenId == 18) return (KnightNftAddr, TokenType.Erc721, 0);
        if (tokenId == 19) return (KingWerewolfNftAddr, TokenType.Erc721, 0);
        if (tokenId == 20) return (QueenVampzNftAddr, TokenType.Erc721, 0);
        if (tokenId == 21) return (KnightMummyNftAddr, TokenType.Erc721, 0);

        return (address(0), TokenType.unknown, 0);
    }

    function _tokenAddr(uint8 tokenId) internal view returns(address) {

        (address addr,, ) = _token(tokenId);
        return addr;
    }

    function _token(
        uint8 tokenId
    ) internal view returns(address, TokenType, uint8 decimals) {

        if (tokenId < extraTokensStartId) return _listedToken(tokenId);

        uint256 i = tokenId - extraTokensStartId;
        Token memory token = _extraTokens[i];
        return (token.addr, token._type, token.decimals);
    }

    function _addTokens(
        address[] memory addresses,
        TokenType[] memory types,
        uint8[] memory decimals
    ) internal {

        require(
            addresses.length == types.length && addresses.length == decimals.length,
            "TokList:INVALID_LISTS_LENGTHS"
        );
        require(
            addresses.length + _extraTokens.length + extraTokensStartId <= 256,
            "TokList:TOO_MANY_TOKENS"
        );
        for (uint256 i = 0; i < addresses.length; i++) {
            require(addresses[i] != address(0), "TokList:INVALID_TOKEN_ADDRESS");
            require(types[i] != TokenType.unknown, "TokList:INVALID_TOKEN_TYPE");
            _extraTokens.push(Token(addresses[i], types[i], decimals[i]));
        }
    }
}// MIT

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.6.0;

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
}// MIT

pragma solidity ^0.6.0;

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

pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.6.2;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.6.0;


library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.6.0;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}pragma solidity 0.6.12;


contract KingDecks is Ownable, ReentrancyGuard, TokenList {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;



    struct Limit {
        uint224 minAmount;
        uint32 maxAmountFactor;
    }

    struct TermSheet {
        uint8 availableQty;
        uint8 inTokenId;
        uint8 nfTokenId;
        uint8 outTokenId;
        uint8 earlyRepayableShare;
        uint8 earlyWithdrawFees;
        uint16 limitId;
        uint16 depositHours;
        uint16 minInterimHours;
        uint64 rate;
        uint64 allowedNftNumBitMask;
    }

    struct Deposit {
        uint176 amountDue;      // Amount due, in "repay" token units
        uint32 maturityTime;    // Time the final withdrawal is allowed since
        uint32 lastWithdrawTime;// Time of the most recent interim withdrawal
        uint16 lockedShare;     // in 1/65535 shares of `amountDue` (see (2))
    }

    struct UserDeposits {
        uint256[] ids;
        mapping(uint256 => Deposit) data;
    }

    uint32 public depositQty;

    address public treasury;

    Limit[] private _limits;

    TermSheet[] internal _termSheets;

    mapping(uint256 => uint256) public totalDue; // in "repay" token units

    mapping(address => UserDeposits) internal _deposits;

    event NewDeposit(
        uint256 indexed inTokenId,
        uint256 indexed outTokenId,
        address indexed user,
        uint256 depositId,
        uint256 termsId,
        uint256 amount, // amount deposited (in deposit token units)
        uint256 amountDue, // amount to be returned (in "repay" token units)
        uint256 maturityTime // UNIX-time when the deposit is unlocked
    );

    event Withdraw(
        address indexed user,
        uint256 depositId,
        uint256 amount // amount sent to user (in deposit token units)
    );

    event InterimWithdraw(
        address indexed user,
        uint256 depositId,
        uint256 amount, // amount sent to user (in "repay" token units)
        uint256 fees // withheld fees (in "repay" token units)
    );

    event NewTermSheet(uint256 indexed termsId);
    event TermsEnabled(uint256 indexed termsId);
    event TermsDisabled(uint256 indexed termsId);

    constructor(address _treasury) public {
        _setTreasury(_treasury);
    }

    function depositIds(
        address user
    ) external view returns (uint256[] memory) {

        _revertZeroAddress(user);
        UserDeposits storage userDeposits = _deposits[user];
        return userDeposits.ids;
    }

    function depositData(
        address user,
        uint256 depositId
    ) external view returns(uint256 termsId, Deposit memory params) {

        params = _deposits[_nonZeroAddr(user)].data[depositId];
        termsId = 0;
        if (params.maturityTime !=0) {
            (termsId, , , ) = _decodeDepositId(depositId);
        }
    }

    function termSheet(
        uint256 termsId
    ) external view returns (TermSheet memory) {

        return _termSheets[_validTermsID(termsId) - 1];
    }

    function termSheetsNum() external view returns (uint256) {

        return _termSheets.length;
    }

    function allTermSheets() external view returns(TermSheet[] memory) {

        return _termSheets;
    }

    function depositLimit(
        uint256 limitId
    ) external view returns (Limit memory) {

        return _limits[_validLimitID(limitId) - 1];
    }

    function depositLimitsNum() external view returns (uint256) {

        return _limits.length;
    }

    function getTokenData(
        uint256 tokenId
    ) external view returns(address, TokenType, uint8 decimals) {

        return _token(uint8(tokenId));
    }

    function isAcceptableNft(
        uint256 termsId,
        address nftContract,
        uint256 nftId
    ) external view returns(bool) {

        TermSheet memory tS = _termSheets[_validTermsID(termsId) - 1];
        if (tS.nfTokenId != 0 && _tokenAddr(tS.nfTokenId) == nftContract) {
            return _isAllowedNftId(nftId, tS.allowedNftNumBitMask);
        }
        return false;
    }

    function idsToBitmask(
        uint256[] memory ids
    ) pure external returns(uint256 bitmask) {

        bitmask = 0;
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            require(id != 0 && id <= 64, "KDecks:unsupported NFT ID");
            bitmask = bitmask | (id == 1 ? 1 : 2 << (id - 2));
        }
    }

    function computeEarlyWithdrawal(
        address user,
        uint256 depositId
    ) external view returns (uint256 amountToUser, uint256 fees) {

        Deposit memory _deposit = _deposits[user].data[depositId];
        require(_deposit.amountDue != 0, "KDecks:unknown or repaid deposit");

        (uint256 termsId, , , ) = _decodeDepositId(depositId);
        TermSheet memory tS = _termSheets[termsId - 1];

        (amountToUser, fees, ) = _computeEarlyWithdrawal(_deposit, tS, now);
    }

    function deposit(
        uint256 termsId,    // term sheet ID
        uint256 amount,     // amount in deposit token units
        uint256 nftId       // ID of the NFT instance (0 if no NFT required)
    ) public nonReentrant {

        TermSheet memory tS = _termSheets[_validTermsID(termsId) - 1];
        require(tS.availableQty != 0, "KDecks:terms disabled or unknown");

        if (tS.availableQty != 255) {
            _termSheets[termsId - 1].availableQty = --tS.availableQty;
            if ( tS.availableQty == 0) emit TermsDisabled(termsId);
        }

        if (tS.limitId != 0) {
            Limit memory l = _limits[tS.limitId - 1];
            require(amount >= l.minAmount, "KDecks:too small deposit amount");
            if (l.maxAmountFactor != 0) {
                require(
                    amount <=
                        uint256(l.minAmount).mul(l.maxAmountFactor) / 1e4,
                    "KDecks:too big deposit amount"
                );
            }
        }

        uint256 serialNum = depositQty + 1;
        depositQty = uint32(serialNum); // overflow risk ignored

        uint256 depositId = _encodeDepositId(
            serialNum,
            termsId,
            tS.outTokenId,
            tS.nfTokenId,
            nftId
        );

        address tokenIn;
        uint256 amountDue;
        {
            uint8 decimalsIn;
            (tokenIn,, decimalsIn) = _token(tS.inTokenId);
            (,, uint8 decimalsOut) = _token(tS.outTokenId);
            amountDue = _amountOut(amount, tS.rate, decimalsIn, decimalsOut);
        }

        require(amountDue < 2**178, "KDecks:O2");
        uint32 maturityTime = safe32(now.add(uint256(tS.depositHours) *3600));

        if (tS.nfTokenId == 0) {
            require(nftId == 0, "KDecks:unexpected non-zero nftId");
        } else {
            require(
                nftId < 2**16 &&
                _isAllowedNftId(nftId, tS.allowedNftNumBitMask),
                "KDecks:disallowed NFT instance"
            );
            IERC721(_tokenAddr(tS.nfTokenId))
                .safeTransferFrom(msg.sender, address(this), nftId, _NFT_PASS);
        }

        IERC20(tokenIn).safeTransferFrom(msg.sender, treasury, amount);

        uint256 lockedShare = uint(255 - tS.earlyRepayableShare) * 65535/255;
        _registerDeposit(
            _deposits[msg.sender],
            depositId,
            Deposit(
                uint176(amountDue),
                maturityTime,
                safe32(now),
                uint16(lockedShare)
            )
        );
        totalDue[tS.outTokenId] = totalDue[tS.outTokenId].add(amountDue);

        emit NewDeposit(
            tS.inTokenId,
            tS.outTokenId,
            msg.sender,
            depositId,
            termsId,
            amount,
            amountDue,
            maturityTime
        );
    }

    function withdraw(uint256 depositId) public nonReentrant {

        _withdraw(depositId, false);
    }

    function interimWithdraw(uint256 depositId) public nonReentrant {

        _withdraw(depositId, true);
    }

    function addTerms(TermSheet[] memory termSheets) public onlyOwner {

        for (uint256 i = 0; i < termSheets.length; i++) {
            _addTermSheet(termSheets[i]);
        }
    }

    function updateAvailableQty(
        uint256 termsId,
        uint256 newQty
    ) external onlyOwner {

        require(newQty <= 255, "KDecks:INVALID_availableQty");
        _termSheets[_validTermsID(termsId) - 1].availableQty = uint8(newQty);
        if (newQty == 0) {
            emit TermsDisabled(termsId);
        } else {
            emit TermsEnabled(termsId);
        }
    }

    function addLimits(Limit[] memory limits) public onlyOwner {

        for (uint256 i = 0; i < limits.length; i++) {
            _addLimit(limits[i]);
        }
    }

    function addTokens(
        address[] memory addresses,
        TokenType[] memory types,
        uint8[] memory decimals
    ) external onlyOwner {

        _addTokens(addresses, types, decimals);
    }

    function setTreasury(address _treasury) public onlyOwner {

        _setTreasury(_treasury);
    }

    function transferFromContract(IERC20 token, uint256 amount, address to)
        external
        onlyOwner
    {

        _revertZeroAddress(to);
        token.safeTransfer(to, amount);
    }

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    bytes private constant _NFT_PASS = abi.encodePacked(bytes4(0xb0e68bdd));

    function onERC721Received(address, address, uint256, bytes calldata data)
        external
        pure
        returns (bytes4)
    {

        return (data.length == 4 && data[0] == 0xb0 && data[3] == 0xdd)
        ? _ERC721_RECEIVED
        : bytes4(0);
    }

    function _encodeDepositId(
        uint256 serialNum,  // Incremental num, unique for every deposit
        uint256 termsId,    // ID of the applicable term sheet
        uint256 outTokenId, // ID of the ERC-20 token to repay deposit in
        uint256 nfTokenId,  // ID of the deposited ERC-721 token (contract)
        uint256 nftId       // ID of the deposited ERC-721 token instance
    ) internal pure returns (uint256 depositId) {

        depositId = nftId
        | (nfTokenId << 16)
        | (outTokenId << 24)
        | (termsId << 32)
        | (serialNum << 48);
    }

    function _decodeDepositId(uint256 depositId) internal pure
    returns (
        uint16 termsId,
        uint8 outTokenId,
        uint8 nfTokenId,
        uint16 nftId
    ) {

        termsId = uint16(depositId >> 32);
        outTokenId = uint8(depositId >> 24);
        nfTokenId = uint8(depositId >> 16);
        nftId = uint16(depositId);
    }

    function _withdraw(uint256 depositId, bool isInterim) internal {

        UserDeposits storage userDeposits = _deposits[msg.sender];
        Deposit memory _deposit = userDeposits.data[depositId];

        require(_deposit.amountDue != 0, "KDecks:unknown or repaid deposit");

        uint256 amountToUser;
        uint256 amountDue = 0;
        uint256 fees = 0;

        (
            uint16 termsId,
            uint8 outTokenId,
            uint8 nfTokenId,
            uint16 nftId
        ) = _decodeDepositId(depositId);

        if (isInterim) {
            TermSheet memory tS = _termSheets[termsId - 1];
            require(
                now >= uint256(_deposit.lastWithdrawTime) + tS.minInterimHours * 3600,
                "KDecks:withdrawal not yet allowed"
            );

            uint256 lockedShare;
            (amountToUser, fees, lockedShare) = _computeEarlyWithdrawal(
                _deposit,
                tS,
                now
            );
            amountDue = uint256(_deposit.amountDue).sub(amountToUser).sub(fees);
            _deposit.lockedShare = uint16(lockedShare);

            emit InterimWithdraw(msg.sender, depositId, amountToUser, fees);
        } else {
            require(now >= _deposit.maturityTime, "KDecks:deposit is locked");
            amountToUser = uint256(_deposit.amountDue);

            if (nftId != 0) {
                IERC721(_tokenAddr(nfTokenId)).safeTransferFrom(
                    address(this),
                    msg.sender,
                    nftId,
                    _NFT_PASS
                );
            }
            _deregisterDeposit(userDeposits, depositId);

            emit Withdraw(msg.sender, depositId, amountToUser);
        }

        _deposit.lastWithdrawTime = safe32(now);
        _deposit.amountDue = uint176(amountDue);
        userDeposits.data[depositId] = _deposit;

        totalDue[outTokenId] = totalDue[outTokenId]
            .sub(amountToUser)
            .sub(fees);

        IERC20(_tokenAddr(outTokenId))
            .safeTransferFrom(treasury, msg.sender, amountToUser);
    }

    function _computeEarlyWithdrawal(
        Deposit memory d,
        TermSheet memory tS,
        uint256 timeNow
    ) internal pure returns (
        uint256 amountToUser,
        uint256 fees,
        uint256 newlockedShare
    ) {

        require(d.lockedShare != 65535, "KDecks:early withdrawals banned");

        amountToUser = 0;
        fees = 0;
        newlockedShare = 0;

        if (timeNow > d.lastWithdrawTime && timeNow < d.maturityTime) {
            {
                uint256 timeSincePrev = timeNow - d.lastWithdrawTime;
                uint256 timeLeftPrev = d.maturityTime - d.lastWithdrawTime;
                uint256 repayable = uint256(d.amountDue)
                    .mul(65535 - d.lockedShare)
                    / 65535;

                amountToUser = repayable.mul(timeSincePrev).div(timeLeftPrev);
                newlockedShare = uint256(65535).sub(
                    repayable.sub(amountToUser)
                    .mul(65535)
                    .div(uint256(d.amountDue).sub(amountToUser))
                );
            }
            {
                uint256 term = uint256(tS.depositHours) * 3600; // can't be 0
                uint256 timeLeft = d.maturityTime - timeNow;
                fees = amountToUser
                    .mul(uint256(tS.earlyWithdrawFees))
                    .mul(timeLeft)
                    / term // fee rate linearly drops to 0
                    / 255; // `earlyWithdrawFees` scaled down

            }
            amountToUser = amountToUser.sub(fees); // fees withheld
        }
    }

    function _amountOut(
        uint256 amount,
        uint64 rate,
        uint8 decIn,
        uint8 decOut
    ) internal pure returns(uint256 out) {

        if (decOut > decIn + 9) { // rate is scaled (multiplied) by 1e9
            out = amount.mul(rate).mul(10 ** uint256(decOut - decIn - 9));
        } else {
            out = amount.mul(rate).div(10 ** uint256(decIn + 9 - decOut));
        }
        return out;
    }

    function _addTermSheet(TermSheet memory tS) internal {

        (, TokenType _type,) = _token(tS.inTokenId);
        require(_type == TokenType.Erc20, "KDecks:INVALID_DEPOSIT_TOKEN");
        (, _type,) = _token(tS.outTokenId);
        require(_type == TokenType.Erc20, "KDecks:INVALID_REPAY_TOKEN");
        if (tS.nfTokenId != 0) {
            (, _type,) = _token(tS.nfTokenId);
            require(_type == TokenType.Erc721, "KDecks:INVALID_NFT_TOKEN");
        }
        if (tS.earlyRepayableShare == 0) {
            require(
                tS.earlyWithdrawFees == 0 && tS.minInterimHours == 0,
                "KDecks:INCONSISTENT_PARAMS"
            );
        }

        if (tS.limitId != 0) _validLimitID(tS.limitId);
        require(
             tS.depositHours != 0 && tS.rate != 0,
            "KDecks:INVALID_ZERO_PARAM"
        );

        _termSheets.push(tS);

        emit NewTermSheet(_termSheets.length);
        if (tS.availableQty != 0 ) emit TermsEnabled(_termSheets.length);
    }

    function _addLimit(Limit memory l) internal {

        require(l.minAmount != 0, "KDecks:INVALID_minAmount");
        _limits.push(l);
    }

    function _isAllowedNftId(
        uint256 nftId,
        uint256 allowedBitMask
    ) internal pure returns(bool) {

        if (allowedBitMask == 0) return true;
        uint256 idBitMask = nftId == 1 ? 1 : (2 << (nftId - 2));
        return (allowedBitMask & idBitMask) != 0;
    }

    function _registerDeposit(
        UserDeposits storage userDeposits,
        uint256 depositId,
        Deposit memory _deposit
    ) internal {

        userDeposits.data[depositId] = _deposit;
        userDeposits.ids.push(depositId);
    }

    function _deregisterDeposit(
        UserDeposits storage userDeposits,
        uint256 depositId
    ) internal {

        _removeArrayElement(userDeposits.ids, depositId);
    }

    function _removeArrayElement(uint256[] storage arr, uint256 el) internal {

        uint256 lastIndex = arr.length - 1;
        if (lastIndex != 0) {
            uint256 replaced = arr[lastIndex];
            if (replaced != el) {
                do {
                    uint256 replacing = replaced;
                    replaced = arr[lastIndex - 1];
                    lastIndex--;
                    arr[lastIndex] = replacing;
                } while (replaced != el && lastIndex != 0);
            }
        }
        arr.pop();
    }

    function _setTreasury(address _treasury) internal {

        _revertZeroAddress(_treasury);
        treasury = _treasury;
    }

    function _revertZeroAddress(address _address) private pure {

        require(_address != address(0), "KDecks:ZERO_ADDRESS");
    }

    function _nonZeroAddr(address _address) private pure returns (address) {

        _revertZeroAddress(_address);
        return _address;
    }

    function _validTermsID(uint256 termsId) private view returns (uint256) {

        require(
            termsId != 0 && termsId <= _termSheets.length,
            "KDecks:INVALID_TERMS_ID"
        );
        return termsId;
    }

    function _validLimitID(uint256 limitId) private view returns (uint256) {

        require(
            limitId != 0 && limitId <= _limits.length,
            "KDecks:INVALID_LIMITS_ID"
        );
        return limitId;
    }

    function safe32(uint256 n) private pure returns (uint32) {

        require(n < 2**32, "KDecks:UNSAFE_UINT32");
        return uint32(n);
    }
}