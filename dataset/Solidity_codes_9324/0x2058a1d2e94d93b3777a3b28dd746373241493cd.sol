

pragma solidity 0.5.7;


library Bytes32Library {

    function bytes32ToBytes(bytes32 data)
        internal
        pure
        returns (bytes memory)
    {

        uint256 i = 0;
        while (i < 32 && uint256(bytes32(data[i])) != 0) {
            ++i;
        }
        bytes memory result = new bytes(i);
        i = 0;
        while (i < 32 && data[i] != 0) {
            result[i] = data[i];
            ++i;
        }
        return result;
    }

    function bytes32ToString(bytes32 data)
        external
        pure
        returns (string memory)
    {

        bytes memory intermediate = bytes32ToBytes(data);
        return string(abi.encodePacked(intermediate));
    }
}


pragma solidity ^0.5.2;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}



pragma solidity 0.5.7;


interface ICore {

    function transferProxy()
        external
        view
        returns (address);


    function vault()
        external
        view
        returns (address);


    function exchangeIds(
        uint8 _exchangeId
    )
        external
        view
        returns (address);


    function validSets(address)
        external
        view
        returns (bool);


    function validModules(address)
        external
        view
        returns (bool);


    function validPriceLibraries(
        address _priceLibrary
    )
        external
        view
        returns (bool);


    function issue(
        address _set,
        uint256 _quantity
    )
        external;


    function issueTo(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;


    function issueInVault(
        address _set,
        uint256 _quantity
    )
        external;


    function redeem(
        address _set,
        uint256 _quantity
    )
        external;


    function redeemTo(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;


    function redeemInVault(
        address _set,
        uint256 _quantity
    )
        external;


    function redeemAndWithdrawTo(
        address _set,
        address _to,
        uint256 _quantity,
        uint256 _toExclude
    )
        external;


    function batchDeposit(
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;


    function batchWithdraw(
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;


    function deposit(
        address _token,
        uint256 _quantity
    )
        external;


    function withdraw(
        address _token,
        uint256 _quantity
    )
        external;


    function internalTransfer(
        address _token,
        address _to,
        uint256 _quantity
    )
        external;


    function createSet(
        address _factory,
        address[] calldata _components,
        uint256[] calldata _units,
        uint256 _naturalUnit,
        bytes32 _name,
        bytes32 _symbol,
        bytes calldata _callData
    )
        external
        returns (address);


    function depositModule(
        address _from,
        address _to,
        address _token,
        uint256 _quantity
    )
        external;


    function withdrawModule(
        address _from,
        address _to,
        address _token,
        uint256 _quantity
    )
        external;


    function batchDepositModule(
        address _from,
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;


    function batchWithdrawModule(
        address _from,
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;


    function issueModule(
        address _owner,
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;


    function redeemModule(
        address _burnAddress,
        address _incrementAddress,
        address _set,
        uint256 _quantity
    )
        external;


    function batchIncrementTokenOwnerModule(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;


    function batchDecrementTokenOwnerModule(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;


    function batchTransferBalanceModule(
        address[] calldata _tokens,
        address _from,
        address _to,
        uint256[] calldata _quantities
    )
        external;


    function transferModule(
        address _token,
        uint256 _quantity,
        address _from,
        address _to
    )
        external;


    function batchTransferModule(
        address[] calldata _tokens,
        uint256[] calldata _quantities,
        address _from,
        address _to
    )
        external;

}



pragma solidity 0.5.7;

interface IWhiteList {



    function whiteList(
        address _address
    )
        external
        view
        returns (bool);


    function areValidAddresses(
        address[] calldata _addresses
    )
        external
        view
        returns (bool);

}



pragma solidity 0.5.7;

library LibBytes {


    using LibBytes for bytes;

    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {

        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    function readBytes4(
        bytes memory b,
        uint256 index)
        internal
        pure
        returns (bytes4 result)
    {

        require(
            b.length >= index + 4,
            "GREATER_OR_EQUAL_TO_4_LENGTH_REQUIRED"
        );
        assembly {
            result := mload(add(b, 32))
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }


    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {

        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        index += 32;

        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {

        if (length < 32) {
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            if (source == dest) {
                return;
            }

            if (source > dest) {
                assembly {
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    let last := mload(sEnd)

                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    let first := mload(source)

                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                    mstore(dest, first)
                }
            }
        }
    }

    function slice(bytes memory b, uint256 from, uint256 to)
        internal
        pure
        returns (bytes memory result)
    {
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to <= b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );

        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length);
        return result;
    }
}



pragma solidity 0.5.7;

interface ISetToken {



    function naturalUnit()
        external
        view
        returns (uint256);


    function getComponents()
        external
        view
        returns (address[] memory);


    function getUnits()
        external
        view
        returns (uint256[] memory);


    function tokenIsComponent(
        address _tokenAddress
    )
        external
        view
        returns (bool);


    function mint(
        address _issuer,
        uint256 _quantity
    )
        external;


    function burn(
        address _from,
        uint256 _quantity
    )
        external;


    function transfer(
        address to,
        uint256 value
    )
        external;

}



pragma solidity 0.5.7;
pragma experimental "ABIEncoderV2";





library SetTokenLibrary {

    using SafeMath for uint256;

    struct SetDetails {
        uint256 naturalUnit;
        address[] components;
        uint256[] units;
    }

    function validateTokensAreComponents(
        address _set,
        address[] calldata _tokens
    )
        external
        view
    {

        for (uint256 i = 0; i < _tokens.length; i++) {
            require(
                ISetToken(_set).tokenIsComponent(_tokens[i]),
                "SetTokenLibrary.validateTokensAreComponents: Component must be a member of Set"
            );

        }
    }

    function isMultipleOfSetNaturalUnit(
        address _set,
        uint256 _quantity
    )
        external
        view
    {

        require(
            _quantity.mod(ISetToken(_set).naturalUnit()) == 0,
            "SetTokenLibrary.isMultipleOfSetNaturalUnit: Quantity is not a multiple of nat unit"
        );
    }

    function requireValidSet(
        ICore _core,
        address _set
    )
        internal
        view
    {

        require(
            _core.validSets(_set),
            "SetTokenLibrary: Must be an approved SetToken address"
        );
    }

    function getSetDetails(
        address _set
    )
        internal
        view
        returns (SetDetails memory)
    {

        ISetToken setToken = ISetToken(_set);

        uint256 naturalUnit = setToken.naturalUnit();
        address[] memory components = setToken.getComponents();
        uint256[] memory units = setToken.getUnits();

        return SetDetails({
            naturalUnit: naturalUnit,
            components: components,
            units: units
        });
    }
}



pragma solidity 0.5.7;







library FactoryUtilsLibrary {

    using SafeMath for uint256;
    using LibBytes for bytes;

    struct InitRebalancingParameters {
        address manager;
        address liquidator;
        address feeRecipient;
        address rebalanceFeeCalculator;
        uint256 rebalanceInterval;
        uint256 rebalanceFailPeriod;
        uint256 lastRebalanceTimestamp;
        uint256 entryFee;
        bytes rebalanceFeeCalculatorData;
    }

    function validateRebalanceSetCalldata(
        InitRebalancingParameters memory _parameters,
        address _liquidatorWhitelist,
        address _feeCalculatorWhitelist,
        uint256 _minimumRebalanceInterval,
        uint256 _minimumFailRebalancePeriod,
        uint256 _maximumFailRebalancePeriod
    )
        public
        view
    {

        require(
            _parameters.manager != address(0),
            "Null manager"
        );

        require(
            _parameters.lastRebalanceTimestamp <= block.timestamp,
            "Bad RebalanceTimestamp"
        );

        require(
            _parameters.liquidator != address(0) &&
            IWhiteList(_liquidatorWhitelist).whiteList(_parameters.liquidator),
            "Bad liquidator"
        );

        require(
            IWhiteList(_feeCalculatorWhitelist).whiteList(address(_parameters.rebalanceFeeCalculator)),
            "Bad fee calculator"
        );

        require(
            _parameters.rebalanceInterval >= _minimumRebalanceInterval,
            "Bad Rebalance interval"
        );

        require(
            _parameters.rebalanceFailPeriod >= _minimumFailRebalancePeriod &&
            _parameters.rebalanceFailPeriod <= _maximumFailRebalancePeriod,
            "Bad Fail Period"
        );
    }

    function parseRebalanceSetCallData(
        bytes memory _callData
    )
        public
        pure
        returns (InitRebalancingParameters memory)
    {

        InitRebalancingParameters memory parameters;

        assembly {
            mstore(parameters,           mload(add(_callData, 32)))   // manager
            mstore(add(parameters, 32),  mload(add(_callData, 64)))   // liquidator
            mstore(add(parameters, 64),  mload(add(_callData, 96)))   // feeRecipient
            mstore(add(parameters, 96),  mload(add(_callData, 128)))  // rebalanceFeeCalculator
            mstore(add(parameters, 128), mload(add(_callData, 160)))  // rebalanceInterval
            mstore(add(parameters, 160), mload(add(_callData, 192)))  // rebalanceFailPeriod
            mstore(add(parameters, 192), mload(add(_callData, 224)))  // lastRebalanceTimestamp
            mstore(add(parameters, 224), mload(add(_callData, 256)))  // entryFee
        }

        parameters.rebalanceFeeCalculatorData = _callData.slice(256, _callData.length);

        return parameters;
    }

    function validateRebalancingSet(
        SetTokenLibrary.SetDetails memory _setDetails,
        address _core,
        address _sender,
        uint256 _minimumNaturalUnit,
        uint256 _maximumNaturalUnit
    )
        public
        view
    {

        ICore coreInstance = ICore(_core);

        require(
            _sender == address(coreInstance),
            "Must be core"
        );

        require(
            _setDetails.components.length == 1 &&
            _setDetails.units.length == 1,
            "Components or units len != 1"
        );

        require(
            _setDetails.units[0] > 0,
            "UnitShares not > 0"
        );

        require(
            coreInstance.validSets(_setDetails.components[0]),
            "Bad Set"
        );

        require(
            _setDetails.naturalUnit >= _minimumNaturalUnit &&
            _setDetails.naturalUnit <= _maximumNaturalUnit,
            "Bad natural unit"
        );
    }
}



pragma solidity 0.5.7;


library RebalancingLibrary {



    enum State { Default, Proposal, Rebalance, Drawdown }


    struct AuctionPriceParameters {
        uint256 auctionStartTime;
        uint256 auctionTimeToPivot;
        uint256 auctionStartPrice;
        uint256 auctionPivotPrice;
    }

    struct BiddingParameters {
        uint256 minimumBid;
        uint256 remainingCurrentSets;
        uint256[] combinedCurrentUnits;
        uint256[] combinedNextSetUnits;
        address[] combinedTokenArray;
    }
}



pragma solidity 0.5.7;



interface IRebalancingSetToken {


    function auctionLibrary()
        external
        view
        returns (address);


    function totalSupply()
        external
        view
        returns (uint256);


    function proposalStartTime()
        external
        view
        returns (uint256);


    function lastRebalanceTimestamp()
        external
        view
        returns (uint256);


    function rebalanceInterval()
        external
        view
        returns (uint256);


    function rebalanceState()
        external
        view
        returns (RebalancingLibrary.State);


    function startingCurrentSetAmount()
        external
        view
        returns (uint256);


    function balanceOf(
        address owner
    )
        external
        view
        returns (uint256);


    function propose(
        address _nextSet,
        address _auctionLibrary,
        uint256 _auctionTimeToPivot,
        uint256 _auctionStartPrice,
        uint256 _auctionPivotPrice
    )
        external;


    function naturalUnit()
        external
        view
        returns (uint256);


    function currentSet()
        external
        view
        returns (address);


    function nextSet()
        external
        view
        returns (address);


    function unitShares()
        external
        view
        returns (uint256);


    function burn(
        address _from,
        uint256 _quantity
    )
        external;


    function placeBid(
        uint256 _quantity
    )
        external
        returns (address[] memory, uint256[] memory, uint256[] memory);


    function getCombinedTokenArrayLength()
        external
        view
        returns (uint256);


    function getCombinedTokenArray()
        external
        view
        returns (address[] memory);


    function getFailedAuctionWithdrawComponents()
        external
        view
        returns (address[] memory);


    function getAuctionPriceParameters()
        external
        view
        returns (uint256[] memory);


    function getBiddingParameters()
        external
        view
        returns (uint256[] memory);


    function getBidPrice(
        uint256 _quantity
    )
        external
        view
        returns (uint256[] memory, uint256[] memory);


}



pragma solidity 0.5.7;



library Rebalance {


    struct TokenFlow {
        address[] addresses;
        uint256[] inflow;
        uint256[] outflow;
    }

    function composeTokenFlow(
        address[] memory _addresses,
        uint256[] memory _inflow,
        uint256[] memory _outflow
    )
        internal
        pure
        returns(TokenFlow memory)
    {

        return TokenFlow({addresses: _addresses, inflow: _inflow, outflow: _outflow });
    }

    function decomposeTokenFlow(TokenFlow memory _tokenFlow)
        internal
        pure
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {

        return (_tokenFlow.addresses, _tokenFlow.inflow, _tokenFlow.outflow);
    }

    function decomposeTokenFlowToBidPrice(TokenFlow memory _tokenFlow)
        internal
        pure
        returns (uint256[] memory, uint256[] memory)
    {

        return (_tokenFlow.inflow, _tokenFlow.outflow);
    }

    function getTokenFlows(
        IRebalancingSetToken _rebalancingSetToken,
        uint256 _quantity
    )
        internal
        view
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {

        address[] memory combinedTokenArray = _rebalancingSetToken.getCombinedTokenArray();

        (
            uint256[] memory inflowArray,
            uint256[] memory outflowArray
        ) = _rebalancingSetToken.getBidPrice(_quantity);

        return (combinedTokenArray, inflowArray, outflowArray);
    }
}



pragma solidity 0.5.7;




interface ILiquidator {



    function startRebalance(
        ISetToken _currentSet,
        ISetToken _nextSet,
        uint256 _startingCurrentSetQuantity,
        bytes calldata _liquidatorData
    )
        external;


    function getBidPrice(
        address _set,
        uint256 _quantity
    )
        external
        view
        returns (Rebalance.TokenFlow memory);


    function placeBid(
        uint256 _quantity
    )
        external
        returns (Rebalance.TokenFlow memory);



    function settleRebalance()
        external;


    function endFailedRebalance() external;



    function auctionPriceParameters(address _set)
        external
        view
        returns (RebalancingLibrary.AuctionPriceParameters memory);



    function hasRebalanceFailed(address _set) external view returns (bool);

    function minimumBid(address _set) external view returns (uint256);

    function startingCurrentSets(address _set) external view returns (uint256);

    function remainingCurrentSets(address _set) external view returns (uint256);

    function getCombinedCurrentSetUnits(address _set) external view returns (uint256[] memory);

    function getCombinedNextSetUnits(address _set) external view returns (uint256[] memory);

    function getCombinedTokenArray(address _set) external view returns (address[] memory);

}



pragma solidity 0.5.7;

interface IFeeCalculator {



    function initialize(
        bytes calldata _feeCalculatorData
    )
        external;


    function getFee()
        external
        view
        returns(uint256);


    function updateAndGetFee()
        external
        returns(uint256);


    function adjustFee(
        bytes calldata _newFeeData
    )
        external;

}



pragma solidity 0.5.7;






interface IRebalancingSetTokenV2 {


    function totalSupply()
        external
        view
        returns (uint256);


    function liquidator()
        external
        view
        returns (ILiquidator);


    function lastRebalanceTimestamp()
        external
        view
        returns (uint256);


    function rebalanceStartTime()
        external
        view
        returns (uint256);


    function startingCurrentSetAmount()
        external
        view
        returns (uint256);


    function rebalanceInterval()
        external
        view
        returns (uint256);


    function getAuctionPriceParameters() external view returns (uint256[] memory);


    function getBiddingParameters() external view returns (uint256[] memory);


    function rebalanceState()
        external
        view
        returns (RebalancingLibrary.State);


    function balanceOf(
        address owner
    )
        external
        view
        returns (uint256);


    function manager()
        external
        view
        returns (address);


    function feeRecipient()
        external
        view
        returns (address);


    function entryFee()
        external
        view
        returns (uint256);


    function rebalanceFee()
        external
        view
        returns (uint256);


    function rebalanceFeeCalculator()
        external
        view
        returns (IFeeCalculator);


    function initialize(
        bytes calldata _rebalanceFeeCalldata
    )
        external;


    function setLiquidator(
        ILiquidator _newLiquidator
    )
        external;


    function setFeeRecipient(
        address _newFeeRecipient
    )
        external;


    function setEntryFee(
        uint256 _newEntryFee
    )
        external;


    function startRebalance(
        address _nextSet,
        bytes calldata _liquidatorData

    )
        external;


    function settleRebalance()
        external;


    function naturalUnit()
        external
        view
        returns (uint256);


    function currentSet()
        external
        view
        returns (ISetToken);


    function nextSet()
        external
        view
        returns (ISetToken);


    function unitShares()
        external
        view
        returns (uint256);


    function placeBid(
        uint256 _quantity
    )
        external
        returns (address[] memory, uint256[] memory, uint256[] memory);


    function getBidPrice(
        uint256 _quantity
    )
        external
        view
        returns (uint256[] memory, uint256[] memory);


    function name()
        external
        view
        returns (string memory);


    function symbol()
        external
        view
        returns (string memory);

}


pragma solidity ^0.5.2;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.2;



contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 value) internal {

        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}


pragma solidity ^0.5.2;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}


pragma solidity >=0.4.24 <0.6.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}



pragma solidity 0.5.7;


interface ISetFactory {



    function core()
        external
        returns (address);


    function createSet(
        address[] calldata _components,
        uint[] calldata _units,
        uint256 _naturalUnit,
        bytes32 _name,
        bytes32 _symbol,
        bytes calldata _callData
    )
        external
        returns (address);

}



pragma solidity 0.5.7;




contract IRebalancingSetFactory is
    ISetFactory
{

    function minimumRebalanceInterval()
        external
        returns (uint256);


    function minimumProposalPeriod()
        external
        returns (uint256);


    function minimumTimeToPivot()
        external
        returns (uint256);


    function maximumTimeToPivot()
        external
        returns (uint256);


    function minimumNaturalUnit()
        external
        returns (uint256);


    function maximumNaturalUnit()
        external
        returns (uint256);


    function rebalanceAuctionModule()
        external
        returns (address);

}



pragma solidity 0.5.7;

interface IVault {


    function withdrawTo(
        address _token,
        address _to,
        uint256 _quantity
    )
        external;


    function incrementTokenOwner(
        address _token,
        address _owner,
        uint256 _quantity
    )
        external;


    function decrementTokenOwner(
        address _token,
        address _owner,
        uint256 _quantity
    )
        external;



    function transferBalance(
        address _token,
        address _from,
        address _to,
        uint256 _quantity
    )
        external;



    function batchWithdrawTo(
        address[] calldata _tokens,
        address _to,
        uint256[] calldata _quantities
    )
        external;


    function batchIncrementTokenOwner(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;


    function batchDecrementTokenOwner(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;


    function batchTransferBalance(
        address[] calldata _tokens,
        address _from,
        address _to,
        uint256[] calldata _quantities
    )
        external;


    function getOwnerBalance(
        address _token,
        address _owner
    )
        external
        view
        returns (uint256);

}



pragma solidity 0.5.7;



library ScaleValidations {

    using SafeMath for uint256;

    uint256 private constant ONE_HUNDRED_PERCENT = 1e18;
    uint256 private constant ONE_BASIS_POINT = 1e14;

    function validateLessThanEqualOneHundredPercent(uint256 _value) internal view {

        require(_value <= ONE_HUNDRED_PERCENT, "Must be <= 100%");
    }

    function validateMultipleOfBasisPoint(uint256 _value) internal view {

        require(
            _value.mod(ONE_BASIS_POINT) == 0,
            "Must be multiple of 0.01%"
        );
    }
}



pragma solidity 0.5.7;











contract RebalancingSetState {




    ICore public core;

    IRebalancingSetFactory public factory;

    IVault public vault;

    IWhiteList public componentWhiteList;

    IWhiteList public liquidatorWhiteList;

    ILiquidator public liquidator;

    IFeeCalculator public rebalanceFeeCalculator;

    address public manager;

    address public feeRecipient;


    uint256 public rebalanceInterval;

    uint256 public rebalanceFailPeriod;

    uint256 public entryFee;


    ISetToken public currentSet;

    uint256 public unitShares;

    uint256 public naturalUnit;

    RebalancingLibrary.State public rebalanceState;

    uint256 public rebalanceIndex;

    uint256 public lastRebalanceTimestamp;


    ISetToken public nextSet;

    uint256 public rebalanceStartTime;

    bool public hasBidded;

    address[] internal failedRebalanceComponents;


    modifier onlyManager() {

        validateManager();
        _;
    }


    event NewManagerAdded(
        address newManager,
        address oldManager
    );

    event NewLiquidatorAdded(
        address newLiquidator,
        address oldLiquidator
    );

    event NewEntryFee(
        uint256 newEntryFee,
        uint256 oldEntryFee
    );

    event NewFeeRecipient(
        address newFeeRecipient,
        address oldFeeRecipient
    );

    event EntryFeePaid(
        address indexed feeRecipient,
        uint256 feeQuantity
    );

    event RebalanceStarted(
        address oldSet,
        address newSet,
        uint256 rebalanceIndex,
        uint256 currentSetQuantity
    );

    event RebalanceSettled(
        address indexed feeRecipient,
        uint256 feeQuantity,
        uint256 feePercentage,
        uint256 rebalanceIndex,
        uint256 issueQuantity,
        uint256 unitShares
    );


    function setManager(
        address _newManager
    )
        external
        onlyManager
    {

        emit NewManagerAdded(_newManager, manager);
        manager = _newManager;
    }

    function setEntryFee(
        uint256 _newEntryFee
    )
        external
        onlyManager
    {

        ScaleValidations.validateLessThanEqualOneHundredPercent(_newEntryFee);

        ScaleValidations.validateMultipleOfBasisPoint(_newEntryFee);

        emit NewEntryFee(_newEntryFee, entryFee);
        entryFee = _newEntryFee;
    }

    function setLiquidator(
        ILiquidator _newLiquidator
    )
        external
        onlyManager
    {

        require(
            rebalanceState != RebalancingLibrary.State.Rebalance,
            "Invalid state"
        );

        require(
            liquidatorWhiteList.whiteList(address(_newLiquidator)),
            "Not whitelisted"
        );

        emit NewLiquidatorAdded(address(_newLiquidator), address(liquidator));
        liquidator = _newLiquidator;
    }

    function setFeeRecipient(
        address _newFeeRecipient
    )
        external
        onlyManager
    {

        emit NewFeeRecipient(_newFeeRecipient, feeRecipient);
        feeRecipient = _newFeeRecipient;
    }


    function rebalanceFee()
        external
        view
        returns (uint256)
    {

        return rebalanceFeeCalculator.getFee();
    }

    function getComponents()
        external
        view
        returns (address[] memory)
    {

        address[] memory components = new address[](1);
        components[0] = address(currentSet);
        return components;
    }

    function getUnits()
        external
        view
        returns (uint256[] memory)
    {

        uint256[] memory units = new uint256[](1);
        units[0] = unitShares;
        return units;
    }

    function tokenIsComponent(
        address _tokenAddress
    )
        external
        view
        returns (bool)
    {

        return _tokenAddress == address(currentSet);
    }

    function validateManager() internal view {

        require(
            msg.sender == manager,
            "Not manager"
        );
    }

    function validateCallerIsCore() internal view {

        require(
            msg.sender == address(core),
            "Not Core"
        );
    }

    function validateCallerIsModule() internal view {

        require(
            core.validModules(msg.sender),
            "Not approved module"
        );
    }

    function validateRebalanceStateIs(RebalancingLibrary.State _requiredState) internal view {

        require(
            rebalanceState == _requiredState,
            "Invalid state"
        );
    }

    function validateRebalanceStateIsNot(RebalancingLibrary.State _requiredState) internal view {

        require(
            rebalanceState != _requiredState,
            "Invalid state"
        );
    }
}



pragma solidity 0.5.7;




contract BackwardCompatibility is
    RebalancingSetState
{


    address public auctionLibrary;

    uint256 public proposalPeriod;

    uint256 public proposalStartTime;


    function getAuctionPriceParameters() external view returns (uint256[] memory) {

        RebalancingLibrary.AuctionPriceParameters memory params = liquidator.auctionPriceParameters(
            address(this)
        );

        uint256[] memory auctionPriceParams = new uint256[](4);
        auctionPriceParams[0] = params.auctionStartTime;
        auctionPriceParams[1] = params.auctionTimeToPivot;
        auctionPriceParams[2] = params.auctionStartPrice;
        auctionPriceParams[3] = params.auctionPivotPrice;

        return auctionPriceParams;
    }

    function getCombinedCurrentUnits() external view returns (uint256[] memory) {

        return liquidator.getCombinedCurrentSetUnits(address(this));
    }

    function getCombinedNextSetUnits() external view returns (uint256[] memory) {

        return liquidator.getCombinedNextSetUnits(address(this));
    }

    function getCombinedTokenArray() external view returns (address[] memory) {

        return liquidator.getCombinedTokenArray(address(this));
    }

    function getCombinedTokenArrayLength() external view returns (uint256) {

        return liquidator.getCombinedTokenArray(address(this)).length;
    }

    function startingCurrentSetAmount() external view returns (uint256) {

        return liquidator.startingCurrentSets(address(this));
    }

    function auctionPriceParameters() external view
        returns (RebalancingLibrary.AuctionPriceParameters memory)
    {

        return liquidator.auctionPriceParameters(address(this));
    }

    function getBiddingParameters() public view returns (uint256[] memory) {

        uint256[] memory biddingParams = new uint256[](2);
        biddingParams[0] = liquidator.minimumBid(address(this));
        biddingParams[1] = liquidator.remainingCurrentSets(address(this));
        return biddingParams;
    }

    function biddingParameters()
        external
        view
        returns (uint256, uint256)
    {

        uint256[] memory biddingParams = getBiddingParameters();
        return (biddingParams[0], biddingParams[1]);
    }

    function getFailedAuctionWithdrawComponents() external view returns (address[] memory) {

        return failedRebalanceComponents;
    }
}


pragma solidity ^0.5.2;

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
}



pragma solidity 0.5.7;


library AddressArrayUtils {


    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {

        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (0, false);
    }

    function contains(address[] memory A, address a) internal pure returns (bool) {

        bool isIn;
        (, isIn) = indexOf(A, a);
        return isIn;
    }

    function extend(address[] memory A, address[] memory B) internal pure returns (address[] memory) {

        uint256 aLength = A.length;
        uint256 bLength = B.length;
        address[] memory newAddresses = new address[](aLength + bLength);
        for (uint256 i = 0; i < aLength; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = 0; j < bLength; j++) {
            newAddresses[aLength + j] = B[j];
        }
        return newAddresses;
    }

    function append(address[] memory A, address a) internal pure returns (address[] memory) {

        address[] memory newAddresses = new address[](A.length + 1);
        for (uint256 i = 0; i < A.length; i++) {
            newAddresses[i] = A[i];
        }
        newAddresses[A.length] = a;
        return newAddresses;
    }

    function intersect(address[] memory A, address[] memory B) internal pure returns (address[] memory) {

        uint256 length = A.length;
        bool[] memory includeMap = new bool[](length);
        uint256 newLength = 0;
        for (uint256 i = 0; i < length; i++) {
            if (contains(B, A[i])) {
                includeMap[i] = true;
                newLength++;
            }
        }
        address[] memory newAddresses = new address[](newLength);
        uint256 j = 0;
        for (uint256 k = 0; k < length; k++) {
            if (includeMap[k]) {
                newAddresses[j] = A[k];
                j++;
            }
        }
        return newAddresses;
    }

    function union(address[] memory A, address[] memory B) internal pure returns (address[] memory) {

        address[] memory leftDifference = difference(A, B);
        address[] memory rightDifference = difference(B, A);
        address[] memory intersection = intersect(A, B);
        return extend(leftDifference, extend(intersection, rightDifference));
    }

    function difference(address[] memory A, address[] memory B) internal pure returns (address[] memory) {

        uint256 length = A.length;
        bool[] memory includeMap = new bool[](length);
        uint256 count = 0;
        for (uint256 i = 0; i < length; i++) {
            address e = A[i];
            if (!contains(B, e)) {
                includeMap[i] = true;
                count++;
            }
        }
        address[] memory newAddresses = new address[](count);
        uint256 j = 0;
        for (uint256 k = 0; k < length; k++) {
            if (includeMap[k]) {
                newAddresses[j] = A[k];
                j++;
            }
        }
        return newAddresses;
    }

    function pop(address[] memory A, uint256 index)
        internal
        pure
        returns (address[] memory, address)
    {

        uint256 length = A.length;
        address[] memory newAddresses = new address[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newAddresses[j - 1] = A[j];
        }
        return (newAddresses, A[index]);
    }

    function remove(address[] memory A, address a)
        internal
        pure
        returns (address[] memory)
    {

        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert();
        } else {
            (address[] memory _A,) = pop(A, index);
            return _A;
        }
    }

    function hasDuplicate(address[] memory A) internal pure returns (bool) {

        if (A.length == 0) {
            return false;
        }
        for (uint256 i = 0; i < A.length - 1; i++) {
            for (uint256 j = i + 1; j < A.length; j++) {
                if (A[i] == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }

    function isEqual(address[] memory A, address[] memory B) internal pure returns (bool) {

        if (A.length != B.length) {
            return false;
        }
        for (uint256 i = 0; i < A.length; i++) {
            if (A[i] != B[i]) {
                return false;
            }
        }
        return true;
    }
}



pragma solidity 0.5.7;



library CommonMath {

    using SafeMath for uint256;

    uint256 public constant SCALE_FACTOR = 10 ** 18;
    uint256 public constant MAX_UINT_256 = 2 ** 256 - 1;

    function scaleFactor()
        internal
        pure
        returns (uint256)
    {

        return SCALE_FACTOR;
    }

    function maxUInt256()
        internal
        pure
        returns (uint256)
    {

        return MAX_UINT_256;
    }

    function scale(
        uint256 a
    )
        internal
        pure
        returns (uint256)
    {

        return a.mul(SCALE_FACTOR);
    }

    function deScale(
        uint256 a
    )
        internal
        pure
        returns (uint256)
    {

        return a.div(SCALE_FACTOR);
    }

    function safePower(
        uint256 a,
        uint256 pow
    )
        internal
        pure
        returns (uint256)
    {

        require(a > 0);

        uint256 result = 1;
        for (uint256 i = 0; i < pow; i++){
            uint256 previousResult = result;

            result = previousResult.mul(a);
        }

        return result;
    }

    function divCeil(uint256 a, uint256 b)
        internal
        pure
        returns(uint256)
    {

        return a.mod(b) > 0 ? a.div(b).add(1) : a.div(b);
    }

    function getPartialAmount(
        uint256 _principal,
        uint256 _numerator,
        uint256 _denominator
    )
        internal
        pure
        returns (uint256)
    {

        uint256 remainder = mulmod(_principal, _numerator, _denominator);

        if (remainder == 0) {
            return _principal.mul(_numerator).div(_denominator);
        }

        uint256 errPercentageTimes1000000 = remainder.mul(1000000).div(_numerator.mul(_principal));

        require(
            errPercentageTimes1000000 < 1000,
            "CommonMath.getPartialAmount: Rounding error exceeds bounds"
        );

        return _principal.mul(_numerator).div(_denominator);
    }

    function ceilLog10(
        uint256 _value
    )
        internal
        pure
        returns (uint256)
    {

        require (
            _value > 0,
            "CommonMath.ceilLog10: Value must be greater than zero."
        );

        if (_value == 1) return 0;

        uint256 x = _value - 1;

        uint256 result = 0;

        if (x >= 10 ** 64) {
            x /= 10 ** 64;
            result += 64;
        }
        if (x >= 10 ** 32) {
            x /= 10 ** 32;
            result += 32;
        }
        if (x >= 10 ** 16) {
            x /= 10 ** 16;
            result += 16;
        }
        if (x >= 10 ** 8) {
            x /= 10 ** 8;
            result += 8;
        }
        if (x >= 10 ** 4) {
            x /= 10 ** 4;
            result += 4;
        }
        if (x >= 100) {
            x /= 100;
            result += 2;
        }
        if (x >= 10) {
            result += 1;
        }

        return result + 1;
    }
}



pragma solidity 0.5.7;











contract RebalancingSettlement is
    ERC20,
    RebalancingSetState
{

    using SafeMath for uint256;

    uint256 public constant SCALE_FACTOR = 10 ** 18;


    function validateRebalancingSettlement()
        internal
        view
    {

        validateRebalanceStateIs(RebalancingLibrary.State.Rebalance);
    }

    function issueNextSet(
        uint256 _issueQuantity
    )
        internal
    {

        core.issueInVault(
            address(nextSet),
            _issueQuantity
        );
    }

    function transitionToDefault(
        uint256 _newUnitShares
    )
        internal
    {

        rebalanceState = RebalancingLibrary.State.Default;
        lastRebalanceTimestamp = block.timestamp;
        currentSet = nextSet;
        unitShares = _newUnitShares;
        rebalanceIndex = rebalanceIndex.add(1);

        nextSet = ISetToken(address(0));
        hasBidded = false;
    }

    function calculateSetIssueQuantity(
        ISetToken _setToken
    )
        internal
        view
        returns (uint256)
    {

        SetTokenLibrary.SetDetails memory setToken = SetTokenLibrary.getSetDetails(address(_setToken));
        uint256 maxIssueAmount = calculateMaxIssueAmount(setToken);

        uint256 issueAmount = maxIssueAmount.sub(maxIssueAmount.mod(setToken.naturalUnit));

        return issueAmount;
    }

    function handleFees()
        internal
        returns (uint256, uint256)
    {

        uint256 feePercent = rebalanceFeeCalculator.getFee();
        uint256 feeQuantity = calculateRebalanceFeeInflation(feePercent);

        if (feeQuantity > 0) {
            ERC20._mint(feeRecipient, feeQuantity);
        }

        return (feePercent, feeQuantity);
    }

    function calculateRebalanceFeeInflation(
        uint256 _rebalanceFeePercent
    )
        internal
        view
        returns(uint256)
    {

        uint256 a = _rebalanceFeePercent.mul(totalSupply());

        uint256 b = SCALE_FACTOR.sub(_rebalanceFeePercent);

        return a.div(b);
    }

    function calculateNextSetNewUnitShares(
        uint256 _issueQuantity
    )
        internal
        view
        returns (uint256)
    {

        uint256 naturalUnitsOutstanding = totalSupply().div(naturalUnit);

        return _issueQuantity.div(naturalUnitsOutstanding);
    }


    function calculateMaxIssueAmount(
        SetTokenLibrary.SetDetails memory _setToken
    )
        private
        view
        returns (uint256)
    {

        uint256 maxIssueAmount = CommonMath.maxUInt256();

        for (uint256 i = 0; i < _setToken.components.length; i++) {
            uint256 componentAmount = vault.getOwnerBalance(
                _setToken.components[i],
                address(this)
            );

            uint256 componentIssueAmount = componentAmount.div(_setToken.units[i]).mul(_setToken.naturalUnit);
            if (componentIssueAmount < maxIssueAmount) {
                maxIssueAmount = componentIssueAmount;
            }
        }

        return maxIssueAmount;
    }
}



pragma solidity 0.5.7;









contract RebalancingFailure is
    RebalancingSetState,
    RebalancingSettlement
{

    using SafeMath for uint256;
    using AddressArrayUtils for address[];


    function validateFailRebalance()
        internal
        view
    {

        validateRebalanceStateIs(RebalancingLibrary.State.Rebalance);

        require(
            liquidatorBreached() || failPeriodBreached(),
            "Triggers not breached"
        );
    }

    function getNewRebalanceState()
        internal
        view
        returns (RebalancingLibrary.State)
    {

        return hasBidded ? RebalancingLibrary.State.Drawdown : RebalancingLibrary.State.Default;
    }

    function transitionToNewState(
        RebalancingLibrary.State _newRebalanceState
    )
        internal
    {

        reissueSetIfRevertToDefault(_newRebalanceState);

        setWithdrawComponentsIfDrawdown(_newRebalanceState);

        rebalanceState = _newRebalanceState;
        rebalanceIndex = rebalanceIndex.add(1);
        lastRebalanceTimestamp = block.timestamp;

        nextSet = ISetToken(address(0));
        hasBidded = false;
    }


    function liquidatorBreached()
        private
        view
        returns (bool)
    {

        return liquidator.hasRebalanceFailed(address(this));
    }

    function failPeriodBreached()
        private
        view
        returns(bool)
    {

        uint256 rebalanceFailTime = rebalanceStartTime.add(rebalanceFailPeriod);

        return block.timestamp >= rebalanceFailTime;
    }

    function reissueSetIfRevertToDefault(
        RebalancingLibrary.State _newRebalanceState
    )
        private
    {

        if (_newRebalanceState ==  RebalancingLibrary.State.Default) {
            uint256 issueQuantity = calculateSetIssueQuantity(currentSet);

            core.issueInVault(
                address(currentSet),
                issueQuantity
            );
        }
    }

    function setWithdrawComponentsIfDrawdown(
        RebalancingLibrary.State _newRebalanceState
    )
        private
    {

        if (_newRebalanceState ==  RebalancingLibrary.State.Drawdown) {
            address[] memory currentSetComponents = currentSet.getComponents();
            address[] memory nextSetComponents = nextSet.getComponents();

            failedRebalanceComponents = currentSetComponents.union(nextSetComponents);
        }
    }
}



pragma solidity 0.5.7;









contract Issuance is
    ERC20,
    RebalancingSetState
{

    using SafeMath for uint256;
    using CommonMath for uint256;


    function validateMint()
        internal
        view
    {

        validateCallerIsCore();

        validateRebalanceStateIs(RebalancingLibrary.State.Default);
    }

    function validateBurn()
        internal
        view
    {

        validateRebalanceStateIsNot(RebalancingLibrary.State.Rebalance);

        if (rebalanceState == RebalancingLibrary.State.Drawdown) {
            validateCallerIsModule();
        } else {
            validateCallerIsCore();
        }
    }
    function handleEntryFees(
        uint256 _quantity
    )
        internal
        returns(uint256)
    {

        uint256 fee = _quantity.mul(entryFee).deScale();

        if (fee > 0) {
            ERC20._mint(feeRecipient, fee);

            emit EntryFeePaid(feeRecipient, fee);
        }

        return _quantity.sub(fee);
    }
}



pragma solidity 0.5.7;







contract RebalancingBid is
    RebalancingSetState
{

    using SafeMath for uint256;


    function validateGetBidPrice(
        uint256 _quantity
    )
        internal
        view
    {

        validateRebalanceStateIs(RebalancingLibrary.State.Rebalance);

        require(
            _quantity > 0,
            "Bid not > 0"
        );
    }

    function validatePlaceBid(
        uint256 _quantity
    )
        internal
        view
    {

        validateCallerIsModule();

        validateGetBidPrice(_quantity);
    }

    function updateHasBiddedIfNecessary()
        internal
    {

        if (!hasBidded) {
            hasBidded = true;
        }
    }

}



pragma solidity 0.5.7;








contract RebalancingStart is
    ERC20,
    RebalancingSetState
{

    using SafeMath for uint256;


    function validateStartRebalance(
        ISetToken _nextSet
    )
        internal
        view
    {

        validateRebalanceStateIs(RebalancingLibrary.State.Default);

        require(
            block.timestamp >= lastRebalanceTimestamp.add(rebalanceInterval),
            "Interval not elapsed"
        );

        require(
            totalSupply() > 0,
            "Invalid supply"
        );

        require(
            core.validSets(address(_nextSet)),
            "Invalid Set"
        );

        require(
            componentWhiteList.areValidAddresses(_nextSet.getComponents()),
            "Invalid component"
        );

        require(
            naturalUnitsAreValid(currentSet, _nextSet),
            "Invalid natural unit"
        );
    }

    function calculateStartingSetQuantity()
        internal
        view
        returns (uint256)
    {

        uint256 currentSetBalance = vault.getOwnerBalance(address(currentSet), address(this));
        uint256 currentSetNaturalUnit = currentSet.naturalUnit();

        return currentSetBalance.sub(currentSetBalance.mod(currentSetNaturalUnit));
    }

    function liquidatorRebalancingStart(
        ISetToken _nextSet,
        uint256 _startingCurrentSetQuantity,
        bytes memory _liquidatorData
    )
        internal
    {

        liquidator.startRebalance(
            currentSet,
            _nextSet,
            _startingCurrentSetQuantity,
            _liquidatorData
        );
    }

    function transitionToRebalance(ISetToken _nextSet) internal {

        nextSet = _nextSet;
        rebalanceState = RebalancingLibrary.State.Rebalance;
        rebalanceStartTime = block.timestamp;
    }


    function naturalUnitsAreValid(
        ISetToken _currentSet,
        ISetToken _nextSet
    )
        private
        view
        returns (bool)
    {

        uint256 currentNaturalUnit = _currentSet.naturalUnit();
        uint256 nextSetNaturalUnit = _nextSet.naturalUnit();

        return Math.max(currentNaturalUnit, nextSetNaturalUnit).mod(
            Math.min(currentNaturalUnit, nextSetNaturalUnit)
        ) == 0;
    }
}



pragma solidity 0.5.7;





















contract RebalancingSetTokenV2 is
    ERC20,
    ERC20Detailed,
    Initializable,
    RebalancingSetState,
    BackwardCompatibility,
    Issuance,
    RebalancingStart,
    RebalancingBid,
    RebalancingSettlement,
    RebalancingFailure
{



    constructor(
        address[8] memory _addressConfig,
        uint256[6] memory _uintConfig,
        string memory _name,
        string memory _symbol
    )
        public
        ERC20Detailed(
            _name,
            _symbol,
            18
        )
    {
        factory = IRebalancingSetFactory(_addressConfig[0]);
        manager = _addressConfig[1];
        liquidator = ILiquidator(_addressConfig[2]);
        currentSet = ISetToken(_addressConfig[3]);
        componentWhiteList = IWhiteList(_addressConfig[4]);
        liquidatorWhiteList = IWhiteList(_addressConfig[5]);
        feeRecipient = _addressConfig[6];
        rebalanceFeeCalculator = IFeeCalculator(_addressConfig[7]);

        unitShares = _uintConfig[0];
        naturalUnit = _uintConfig[1];
        rebalanceInterval = _uintConfig[2];
        rebalanceFailPeriod = _uintConfig[3];
        lastRebalanceTimestamp = _uintConfig[4];
        entryFee = _uintConfig[5];

        core = ICore(factory.core());
        vault = IVault(core.vault());
        rebalanceState = RebalancingLibrary.State.Default;
    }

    function initialize(
        bytes calldata _rebalanceFeeCalldata
    )
        external
        initializer
    {

        rebalanceFeeCalculator.initialize(_rebalanceFeeCalldata);
    }


    function startRebalance(
        ISetToken _nextSet,
        bytes calldata _liquidatorData
    )
        external
        onlyManager
    {

        RebalancingStart.validateStartRebalance(_nextSet);

        uint256 startingCurrentSetQuantity = RebalancingStart.calculateStartingSetQuantity();

        core.redeemInVault(address(currentSet), startingCurrentSetQuantity);

        RebalancingStart.liquidatorRebalancingStart(_nextSet, startingCurrentSetQuantity, _liquidatorData);

        RebalancingStart.transitionToRebalance(_nextSet);

        emit RebalanceStarted(
            address(currentSet),
            address(nextSet),
            rebalanceIndex,
            startingCurrentSetQuantity
        );
    }

    function getBidPrice(
        uint256 _quantity
    )
        public
        view
        returns (uint256[] memory, uint256[] memory)
    {

        RebalancingBid.validateGetBidPrice(_quantity);

        return Rebalance.decomposeTokenFlowToBidPrice(
            liquidator.getBidPrice(address(this), _quantity)
        );
    }

    function placeBid(
        uint256 _quantity
    )
        external
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {

        RebalancingBid.validatePlaceBid(_quantity);

        Rebalance.TokenFlow memory tokenFlow = liquidator.placeBid(_quantity);

        RebalancingBid.updateHasBiddedIfNecessary();

        return Rebalance.decomposeTokenFlow(tokenFlow);
    }

    function settleRebalance()
        external
    {

        RebalancingSettlement.validateRebalancingSettlement();

        uint256 issueQuantity = RebalancingSettlement.calculateSetIssueQuantity(nextSet);

        (uint256 feePercent, uint256 feeQuantity) = RebalancingSettlement.handleFees();

        uint256 newUnitShares = RebalancingSettlement.calculateNextSetNewUnitShares(issueQuantity);

        require(
            newUnitShares > 0,
            "Failed: unitshares is 0."
        );

        RebalancingSettlement.issueNextSet(issueQuantity);

        liquidator.settleRebalance();

        emit RebalanceSettled(
            feeRecipient,
            feeQuantity,
            feePercent,
            rebalanceIndex,
            issueQuantity,
            newUnitShares
        );

        RebalancingSettlement.transitionToDefault(newUnitShares);

    }

    function endFailedRebalance()
        public
    {

        RebalancingFailure.validateFailRebalance();

        RebalancingLibrary.State newRebalanceState = RebalancingFailure.getNewRebalanceState();

        liquidator.endFailedRebalance();

        RebalancingFailure.transitionToNewState(newRebalanceState);
    }

    function mint(
        address _issuer,
        uint256 _quantity
    )
        external
    {

        Issuance.validateMint();

        uint256 issueQuantityNetOfFees = Issuance.handleEntryFees(_quantity);

        ERC20._mint(_issuer, issueQuantityNetOfFees);
    }

    function burn(
        address _from,
        uint256 _quantity
    )
        external
    {

        Issuance.validateBurn();

        ERC20._burn(_from, _quantity);
    }


    function endFailedAuction() external {

        endFailedRebalance();
    }
}



pragma solidity 0.5.7;










contract RebalancingSetTokenV2Factory {

    using LibBytes for bytes;
    using Bytes32Library for bytes32;


    ICore public core;

    IWhiteList public rebalanceComponentWhitelist;

    IWhiteList public liquidatorWhitelist;

    IWhiteList public feeCalculatorWhitelist;

    uint256 public minimumRebalanceInterval;

    uint256 public minimumFailRebalancePeriod;

    uint256 public maximumFailRebalancePeriod;

    uint256 public minimumNaturalUnit;

    uint256 public maximumNaturalUnit;


    struct InitRebalancingParameters {
        address manager;
        ILiquidator liquidator;
        address feeRecipient;
        address rebalanceFeeCalculator;
        uint256 rebalanceInterval;
        uint256 rebalanceFailPeriod;
        uint256 lastRebalanceTimestamp;
        uint256 entryFee;
        bytes rebalanceFeeCalculatorData;
    }


    constructor(
        ICore _core,
        IWhiteList _componentWhitelist,
        IWhiteList _liquidatorWhitelist,
        IWhiteList _feeCalculatorWhitelist,
        uint256 _minimumRebalanceInterval,
        uint256 _minimumFailRebalancePeriod,
        uint256 _maximumFailRebalancePeriod,
        uint256 _minimumNaturalUnit,
        uint256 _maximumNaturalUnit
    )
        public
    {
        core = _core;
        rebalanceComponentWhitelist = _componentWhitelist;
        liquidatorWhitelist = _liquidatorWhitelist;
        feeCalculatorWhitelist = _feeCalculatorWhitelist;
        minimumRebalanceInterval = _minimumRebalanceInterval;
        minimumFailRebalancePeriod = _minimumFailRebalancePeriod;
        maximumFailRebalancePeriod = _maximumFailRebalancePeriod;
        minimumNaturalUnit = _minimumNaturalUnit;
        maximumNaturalUnit = _maximumNaturalUnit;
    }


    function createSet(
        address[] calldata _components,
        uint256[] calldata _units,
        uint256 _naturalUnit,
        bytes32 _name,
        bytes32 _symbol,
        bytes calldata _callData
    )
        external
        returns (address)
    {

        require(
            msg.sender == address(core),
            "Sender must be core"
        );

        require(
            _components.length == 1 &&
            _units.length == 1,
            "Components & units must be len 1"
        );

        require(
            _units[0] > 0,
            "UnitShares not > 0"
        );

        address startingSet = _components[0];

        require(
            core.validSets(startingSet),
            "Invalid SetToken"
        );

        require(
            _naturalUnit >= minimumNaturalUnit && _naturalUnit <= maximumNaturalUnit,
            "Invalid natural unit"
        );

        InitRebalancingParameters memory parameters = parseRebalanceSetCallData(_callData);

        require(
            parameters.manager != address(0),
            "Invalid manager"
        );

        require(
            address(parameters.liquidator) != address(0) &&
            liquidatorWhitelist.whiteList(address(parameters.liquidator)),
            "Invalid liquidator"
        );

        require(
            feeCalculatorWhitelist.whiteList(address(parameters.rebalanceFeeCalculator)),
            "Invalid fee calculator"
        );

        require(
            parameters.rebalanceInterval >= minimumRebalanceInterval,
            "Rebalance interval too short"
        );

        require(
            parameters.rebalanceFailPeriod >= minimumFailRebalancePeriod &&
            parameters.rebalanceFailPeriod <= maximumFailRebalancePeriod,
            "Invalid Fail Period"
        );

        require(
            parameters.lastRebalanceTimestamp <= block.timestamp,
            "Invalid RebalanceTimestamp"
        );

        address rebalancingSet = address(
            new RebalancingSetTokenV2(
                [
                    address(this),                          // factory
                    parameters.manager,                     // manager
                    address(parameters.liquidator),         // liquidator
                    startingSet,                            // initialSet
                    address(rebalanceComponentWhitelist),   // componentWhiteList
                    address(liquidatorWhitelist),           // liquidatorWhiteList
                    parameters.feeRecipient,                // feeRecipient
                    parameters.rebalanceFeeCalculator       // rebalanceFeeCalculator
                ],
                [
                    _units[0],                              // unitShares
                    _naturalUnit,                           // naturalUnit
                    parameters.rebalanceInterval,           // rebalanceInterval
                    parameters.rebalanceFailPeriod,         // rebalanceFailPeriod
                    parameters.lastRebalanceTimestamp,      // lastRebalanceTimestamp
                    parameters.entryFee                     // entryFee
                ],
                _name.bytes32ToString(),
                _symbol.bytes32ToString()
            )
        );

        IRebalancingSetTokenV2(rebalancingSet).initialize(parameters.rebalanceFeeCalculatorData);

        return rebalancingSet;
    }


    function parseRebalanceSetCallData(
        bytes memory _callData
    )
        private
        pure
        returns (InitRebalancingParameters memory)
    {

        InitRebalancingParameters memory parameters;

        assembly {
            mstore(parameters,           mload(add(_callData, 32)))   // manager
            mstore(add(parameters, 32),  mload(add(_callData, 64)))   // liquidator
            mstore(add(parameters, 64),  mload(add(_callData, 96)))   // feeRecipient
            mstore(add(parameters, 96),  mload(add(_callData, 128)))  // rebalanceFeeCalculator
            mstore(add(parameters, 128), mload(add(_callData, 160)))  // rebalanceInterval
            mstore(add(parameters, 160), mload(add(_callData, 192)))  // rebalanceFailPeriod
            mstore(add(parameters, 192), mload(add(_callData, 224)))  // lastRebalanceTimestamp
            mstore(add(parameters, 224), mload(add(_callData, 256)))  // entryFee
        }

        parameters.rebalanceFeeCalculatorData = _callData.slice(256, _callData.length);

        return parameters;
    }
}



pragma solidity 0.5.7;







contract IncentiveFee is
    ERC20,
    RebalancingSetState
{

    using SafeMath for uint256;
    using CommonMath for uint256;


    event IncentiveFeePaid(
        address indexed feeRecipient,
        uint256 feeQuantity,
        uint256 feePercentage,
        uint256 newUnitShares
    );


    function handleFees()
        internal
        returns (uint256, uint256)
    {

        uint256 feePercent = rebalanceFeeCalculator.updateAndGetFee();
        uint256 feeQuantity = calculateIncentiveFeeInflation(feePercent);

        if (feeQuantity > 0) {
            ERC20._mint(feeRecipient, feeQuantity);
        }

        return (feePercent, feeQuantity);
    }

    function calculateIncentiveFeeInflation(
        uint256 _feePercentage
    )
        internal
        view
        returns(uint256)
    {

        uint256 a = _feePercentage.mul(totalSupply());

        uint256 b = CommonMath.scaleFactor().sub(_feePercentage);

        return a.div(b);
    }

    function validateFeeActualization() internal view {

        validateRebalanceStateIs(RebalancingLibrary.State.Default);
    }

    function calculateNewUnitShares() internal view returns(uint256) {

        uint256 currentSetAmount = vault.getOwnerBalance(
            address(currentSet),
            address(this)
        );

        return currentSetAmount.mul(naturalUnit).divCeil(totalSupply());
    }
}



pragma solidity 0.5.7;





contract RebalancingSetTokenV3 is
    IncentiveFee,
    RebalancingSetTokenV2
{


    constructor(
        address[8] memory _addressConfig,
        uint256[6] memory _uintConfig,
        string memory _name,
        string memory _symbol
    )
        public
        RebalancingSetTokenV2(
            _addressConfig,
            _uintConfig,
            _name,
            _symbol
        )
    {}

    function settleRebalance()
        external
    {

        RebalancingSettlement.validateRebalancingSettlement();

        uint256 issueQuantity = RebalancingSettlement.calculateSetIssueQuantity(nextSet);
        uint256 newUnitShares = RebalancingSettlement.calculateNextSetNewUnitShares(issueQuantity);

        validateUnitShares(newUnitShares);

        RebalancingSettlement.issueNextSet(issueQuantity);

        liquidator.settleRebalance();

        emit RebalanceSettled(
            address(0),      // No longer used
            0,               // No longer used
            0,               // No longer used
            rebalanceIndex,  // Current Rebalance index
            issueQuantity,
            newUnitShares
        );

        RebalancingSettlement.transitionToDefault(newUnitShares);
    }

    function actualizeFee()
        public
    {

        IncentiveFee.validateFeeActualization();

        (uint256 feePercent, uint256 feeQuantity) = IncentiveFee.handleFees();

        uint256 newUnitShares = IncentiveFee.calculateNewUnitShares();

        validateUnitShares(newUnitShares);

        unitShares = newUnitShares;

        emit IncentiveFeePaid(
            feeRecipient,
            feeQuantity,
            feePercent,
            newUnitShares
        );
    }

    function adjustFee(
        bytes calldata _newFeeData
    )
        external
        onlyManager
    {

        actualizeFee();

        rebalanceFeeCalculator.adjustFee(_newFeeData);
    }


    function validateUnitShares(uint256 _newUnitShares) internal view {

        require(
            _newUnitShares > 0,
            "Unitshares is 0"
        );
    }
}



pragma solidity 0.5.7;













contract RebalancingSetTokenV3Factory is RebalancingSetTokenV2Factory {



    constructor(
        ICore _core,
        IWhiteList _componentWhitelist,
        IWhiteList _liquidatorWhitelist,
        IWhiteList _feeCalculatorWhitelist,
        uint256 _minimumRebalanceInterval,
        uint256 _minimumFailRebalancePeriod,
        uint256 _maximumFailRebalancePeriod,
        uint256 _minimumNaturalUnit,
        uint256 _maximumNaturalUnit
    )
        public
        RebalancingSetTokenV2Factory(
            _core,
            _componentWhitelist,
            _liquidatorWhitelist,
            _feeCalculatorWhitelist,
            _minimumRebalanceInterval,
            _minimumFailRebalancePeriod,
            _maximumFailRebalancePeriod,
            _minimumNaturalUnit,
            _maximumNaturalUnit
        )
    {}


    function createSet(
        address[] calldata _components,
        uint256[] calldata _units,
        uint256 _naturalUnit,
        bytes32 _name,
        bytes32 _symbol,
        bytes calldata _callData
    )
        external
        returns (address)
    {

        SetTokenLibrary.SetDetails memory rebalancingSetDetails = SetTokenLibrary.SetDetails({
            naturalUnit: _naturalUnit,
            components: _components,
            units: _units
        });

        FactoryUtilsLibrary.validateRebalancingSet(
            rebalancingSetDetails,
            address(core),
            msg.sender,
            minimumNaturalUnit,
            maximumNaturalUnit
        );

        FactoryUtilsLibrary.InitRebalancingParameters memory parameters =
            FactoryUtilsLibrary.parseRebalanceSetCallData(_callData);

        FactoryUtilsLibrary.validateRebalanceSetCalldata(
            parameters,
            address(liquidatorWhitelist),
            address(feeCalculatorWhitelist),
            minimumRebalanceInterval,
            minimumFailRebalancePeriod,
            maximumFailRebalancePeriod
        );

        address rebalancingSet = address(
            new RebalancingSetTokenV3(
                [
                    address(this),                          // factory
                    parameters.manager,                     // manager
                    parameters.liquidator,                  // liquidator
                    _components[0],                            // initialSet
                    address(rebalanceComponentWhitelist),   // componentWhiteList
                    address(liquidatorWhitelist),           // liquidatorWhiteList
                    parameters.feeRecipient,                // feeRecipient
                    parameters.rebalanceFeeCalculator       // rebalanceFeeCalculator
                ],
                [
                    _units[0],                              // unitShares
                    _naturalUnit,                           // naturalUnit
                    parameters.rebalanceInterval,           // rebalanceInterval
                    parameters.rebalanceFailPeriod,         // rebalanceFailPeriod
                    parameters.lastRebalanceTimestamp,      // lastRebalanceTimestamp
                    parameters.entryFee                     // entryFee
                ],
                _name.bytes32ToString(),
                _symbol.bytes32ToString()
            )
        );

        IRebalancingSetTokenV2(rebalancingSet).initialize(parameters.rebalanceFeeCalculatorData);

        return rebalancingSet;
    }
}