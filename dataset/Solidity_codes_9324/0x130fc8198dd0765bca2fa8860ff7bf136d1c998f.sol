
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

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
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT
pragma solidity ^0.8.4;



interface IVesting {

   function vest(address _beneficiary, uint256 _amount) external payable;

}

interface IMintable {

    function mint(address _to, uint256 _value) external;

}

library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
}

contract BasicAuction is Ownable, Pausable {

    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20 public immutable mainToken;  //          BOOT token
    IERC721 public immutable nft;       // NFT contract required for early access

    uint public constant decimals = 18;
    uint public constant coin = 10 ** decimals;
    uint public constant firstEra = 1;

    address payable destAddress;

    uint public secondsPerAuction;
    uint public auctionsPerEra;
    uint public firstPublicAuction;
    uint public totalSupply;        // MainToken supply allocated to public sale
    uint public remainingSupply;
    uint public initialEmission;
    uint public emissionDecayRate; // e.g. 1_000 constant, 0_618 golden ratio decay
    uint public currentEra;
    uint public currentAuction;
    uint public nextEraTime;
    uint public nextAuctionTime;
    uint public totalContributed;
    uint public totalEmitted;
    uint public ewma;
    uint private emission;

    mapping(uint => uint) public mapEra_Emission;
    mapping(uint => mapping(uint => uint)) public mapEraAuction_MemberCount;
    mapping(uint => mapping(uint => address[])) public mapEraAuction_Members;
    mapping(uint => mapping(uint => uint)) public mapEraAuction_Units;
    mapping(uint => mapping(uint => uint)) public mapEraAuction_UnitsRemaining;
    mapping(uint => mapping(uint => uint)) public mapEraAuction_EmissionRemaining;
    mapping(uint => mapping(uint => mapping(address => uint))) public mapEraAuction_MemberUnitsRemaining;
    mapping(address => mapping(uint => uint[])) public mapMemberEra_Auctions;

    event NewEra(uint era, uint emission, uint time, uint totalContributed);
    event NewAuction(uint era, uint auction, uint time, uint previousAuctionTotal, uint previousAuctionMembers, uint historicEWMA);
    event Contribution(address indexed payer, address indexed member, uint era, uint auction, uint units, uint dailyTotal);
    event Withdrawal(address indexed caller, address indexed member, uint era, uint auction, uint value, uint remaining);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(
        IERC20 _mainToken,
        IERC721 _nft,
        uint _secondsPerAuction,
        uint _auctionsPerEra,
        uint _firstPublicAuction,
        uint _totalSupply,
        uint _initialEmission,
        uint _emissionDecayRate,
        address payable _destAddress)
    {
        require(address(_mainToken) != address(0), "Invalid _mainToken address");
        require(address(_nft) != address(0), "Invalid _nft address");
        require(address(_destAddress) != address(0), "Invalid _destAddress");

        mainToken = _mainToken;
        nft = _nft;

        currentEra = 1;
        currentAuction = 1;
        totalContributed = 0;
        totalEmitted = 0;

        secondsPerAuction = _secondsPerAuction;
        auctionsPerEra = _auctionsPerEra;
        firstPublicAuction = _firstPublicAuction;
        totalSupply = _totalSupply;
        initialEmission = _initialEmission;
        emissionDecayRate = _emissionDecayRate;

        emission = initialEmission; // current auction's theoretical emission regardless of actual supply
        remainingSupply = _totalSupply; // remaining actual supply including for the current auction

        destAddress = _destAddress;

        nextEraTime = block.timestamp + secondsPerAuction * auctionsPerEra;
        nextAuctionTime = block.timestamp + secondsPerAuction;
        mapEra_Emission[currentEra] = emission;
        mapEraAuction_EmissionRemaining[currentEra][currentAuction] = emission;
    }

    function setDestination(address payable _destAddress) public onlyOwner {

        require(address(_destAddress) != address(0), "Invalid _destAddress");
        destAddress = _destAddress;
    }

    receive() external payable whenNotPaused {
        _contributeForMember(msg.sender);
    }

    function contributeForMember(address member) external payable whenNotPaused {

        _contributeForMember(member);
    }

    function _contributeForMember(address member) private {

        require(msg.value > 0, "Some ether should be sent");
        _updateEmission();
        require(remainingSupply > 0, "public sale has ended");
        if (currentEra == 1 && currentAuction < firstPublicAuction) {
            require(nft.balanceOf(member) > 0, "NFT required to participate.");
        }
        _withdrawPrior(member);
        _recordContribution(msg.sender, member, currentEra, currentAuction, msg.value);
        (bool success, /*bytes memory data*/) = destAddress.call{value: msg.value}("");
        require(success, "");
    }

    function _recordContribution(address _payer, address _member, uint _era, uint _auction, uint _eth) private {

        if (mapEraAuction_MemberUnitsRemaining[_era][_auction][_member] == 0) {
            mapMemberEra_Auctions[_member][_era].push(_auction);
            mapEraAuction_MemberCount[_era][_auction] += 1;
            mapEraAuction_Members[_era][_auction].push(_member);
        }
        mapEraAuction_MemberUnitsRemaining[_era][_auction][_member] += _eth;
        mapEraAuction_Units[_era][_auction] += _eth;
        mapEraAuction_UnitsRemaining[_era][_auction] += _eth;
        totalContributed += _eth;
        emit Contribution(_payer, _member, _era, _auction, _eth, mapEraAuction_Units[_era][_auction]);
    }

    function getAuctionsContributedForEra(address member, uint era) public view returns(uint) {

        return mapMemberEra_Auctions[member][era].length;
    }

    function withdrawShare(uint era, uint auction) external returns (uint) {

        require(era >= 1, "era must be >= 1");
        require(auction >= 1, "auction must be >= 1");
        require(auction <= auctionsPerEra, "auction must be <= auctionsPerEra");
        _updateEmission();
        return _withdrawShare(era, auction, msg.sender);                           
    }

    function batchWithdraw(uint era, uint[] memory arrayAuctions) external returns (uint value) {

        _updateEmission();
        for (uint i = 0; i < arrayAuctions.length; ++i) {
            value += _prepareWithdrawShare(era, arrayAuctions[i], msg.sender);
        }
        _mint(value, msg.sender);
    }

    function _withdrawPrior(address member) private {

        for (uint era = currentEra; era >= 1; --era) {
            uint i = mapMemberEra_Auctions[member][era].length;
            while (i > 0) {
                --i;
                uint auction = mapMemberEra_Auctions[member][era][i];
                if (era != currentEra || auction != currentAuction) {
                    uint units = mapEraAuction_MemberUnitsRemaining[era][auction][member];
                    if (units > 0) {
                        uint value = _prepareWithdrawUnits(era, auction, member, units);
                        _mint(value, member);
                        return;
                    }
                }
            }
        }
    }

    function withdrawAll(uint era) external returns (uint value) {

        _updateEmission();
        uint length = mapMemberEra_Auctions[msg.sender][era].length;
        for (uint i = 0; i < length; ++i) {
            uint auction = mapMemberEra_Auctions[msg.sender][era][i];
            value += _prepareWithdrawShare(era, auction, msg.sender);
        }
        _mint(value, msg.sender);
    }

    function withdrawAll() external returns (uint value) {

        _updateEmission();
        for (uint era = 1; era <= currentEra; ++era) {
            uint length = mapMemberEra_Auctions[msg.sender][era].length;
            for (uint i = 0; i < length; ++i) {
                uint auction = mapMemberEra_Auctions[msg.sender][era][i];
                value += _prepareWithdrawShare(era, auction, msg.sender);
            }
        }
        _mint(value, msg.sender);
    }

    function _mint(uint value, address _member) private {

        IMintable(address(mainToken)).mint(_member, value);
    }

    function _prepareWithdrawShare (uint _era, uint _auction, address _member) private returns (uint value) {
        if (_era < currentEra) {
            value = _prepareWithdrawal(_era, _auction, _member);
        }
        else if (_era == currentEra && _auction < currentAuction) {
            value = _prepareWithdrawal(_era, _auction, _member);
        }
    }

    function _withdrawShare (uint _era, uint _auction, address _member) private returns (uint value) {
        if (_era < currentEra) {
            value = _prepareWithdrawal(_era, _auction, _member);
            _mint(value, _member);
        }
        else if (_era == currentEra && _auction < currentAuction) {
            value = _prepareWithdrawal(_era, _auction, _member);
            _mint(value, _member);
        }  
    }

    function _prepareWithdrawal (uint _era, uint _auction, address _member) private returns (uint value) {
        uint memberUnits = mapEraAuction_MemberUnitsRemaining[_era][_auction][_member];
        if (memberUnits != 0) {
            value = _prepareWithdrawUnits(_era, _auction, _member, memberUnits);
        }
    }

    function _prepareWithdrawUnits(uint _era, uint _auction, address _member, uint memberUnits) private returns (uint value) {

        uint totalUnits = mapEraAuction_UnitsRemaining[_era][_auction];
        uint emissionRemaining = mapEraAuction_EmissionRemaining[_era][_auction];
        value = (emissionRemaining * memberUnits) / totalUnits;
        mapEraAuction_MemberUnitsRemaining[_era][_auction][_member] = 0; // since it will be withdrawn
        mapEraAuction_UnitsRemaining[_era][_auction] = mapEraAuction_UnitsRemaining[_era][_auction].sub(memberUnits);
        mapEraAuction_EmissionRemaining[_era][_auction] = mapEraAuction_EmissionRemaining[_era][_auction].sub(value);
        emit Withdrawal(msg.sender, _member, _era, _auction, value, mapEraAuction_EmissionRemaining[_era][_auction]);
    }

    function getEmissionShare(uint era, uint auction, address member) public view returns (uint value) {

        uint memberUnits = mapEraAuction_MemberUnitsRemaining[era][auction][member];
        if (memberUnits != 0) {
            uint totalUnits = mapEraAuction_UnitsRemaining[era][auction];
            uint emissionRemaining = mapEraAuction_EmissionRemaining[era][auction];
            value = (emissionRemaining * memberUnits) / totalUnits;
        }
    }
    
    function _updateEmission() private {

        uint _now = block.timestamp;
        if (_now >= nextAuctionTime) {
            uint members = mapEraAuction_MemberCount[currentEra][currentAuction];
            uint units = mapEraAuction_Units[currentEra][currentAuction];
			if (units > 0) {
				uint price = 10**9 * (units / (emission / 10**9));
				ewma = ewma == 0 ? price : (3 * price + 2 * ewma) / 5; // apha = 0.6
			}
            if (remainingSupply > emission) {
                remainingSupply -= emission;
            }
            else {
                remainingSupply = 0;
            }
            if (currentAuction >= auctionsPerEra) {
                currentEra += 1;
                currentAuction = 0;
                nextEraTime = _now + secondsPerAuction * auctionsPerEra;
                emission = getNextEraEmission();
                mapEra_Emission[currentEra] = emission;
                emit NewEra(currentEra, emission, nextEraTime, totalContributed);
            }
            currentAuction += 1;
            nextAuctionTime = _now + secondsPerAuction;
            if (remainingSupply < emission) {
                emission = remainingSupply;
            }
            mapEraAuction_EmissionRemaining[currentEra][currentAuction] = emission;

            emit NewAuction(currentEra, currentAuction, nextAuctionTime, units, members, ewma);
        }
    }

    function getImpliedPriceEWMA(bool includeCurrentEra) public view returns (uint) {

        if (ewma == 0 || includeCurrentEra) {
            uint price = 10**9 * (mapEraAuction_Units[currentEra][currentAuction] / (emission / 10**9));
			return ewma == 0 ? price : (3 * price + 2 * ewma) / 5; // apha = 0.6
        }
        else {
            return ewma;
        }
    }

    function updateEmission() external {

        _updateEmission();
    }

    function getNextEraEmission() public view returns (uint) {

        if (emissionDecayRate == 1000) {
            return emission;
        }
        else {
            return emission * emissionDecayRate / 1000;
        }
    }

    function getAuctionEmission() public view returns (uint) {

        return emission;
    }

    function pause() public onlyOwner whenNotPaused {

        _pause();
    }

    function unpause() public onlyOwner whenPaused {

        _unpause();
    }
}

contract Auction is BasicAuction {

    constructor(IERC20 _mainToken, IERC721 _nft)
        BasicAuction(
            _mainToken,
            _nft,

            7 * 86400, // secondsPerAuction

            52, // auctionsPerEra
            5,  // firstPublicAuction

            12_499_968_000000000000000000, // totalSupply for entire sale period
                80_128_000000000000000000, // initial auction emission = totalSupply / 3 / 52

            1_000, // decay rate per era

            payable(address(0x03Df4ADDfB568b338f6a0266f30458045bbEFbF2)))
    {}
}