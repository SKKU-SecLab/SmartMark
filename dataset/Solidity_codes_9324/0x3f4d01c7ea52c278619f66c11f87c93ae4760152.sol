


pragma solidity 0.8.4;

interface IOracle {

    function getTokensOwed(uint256 ethOwed, address pToken, address uTokenLink) external view returns (uint256);

    function getEthOwed(uint256 tokensOwed, address pToken, address uTokenLink) external view returns (uint256);

}


pragma solidity 0.8.4;

interface ICovBase {

    function editShield(address shield, bool active) external;

    function updateShield(uint256 ethValue) external payable;

    function checkCoverage(uint256 pAmount) external view returns (bool);

    function getShieldOwed(address shield) external view returns (uint256);

}


pragma solidity 0.8.4;

interface IController {

    function bonus() external view returns (uint256);

    function refFee() external view returns (uint256);

    function governor() external view returns (address);

    function depositAmt() external view returns (uint256);

    function beneficiary() external view returns (address payable);

    function emitAction(
        address _user,
        address _referral,
        address _shield,
        address _pToken,
        uint256 _amount,
        uint256 _refFee,
        bool _mint
    ) external;

}


pragma solidity 0.8.4;

interface IArmorToken {


    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    
    function mint(address to, uint256 amount) external returns (bool);

    function burn(uint256 amount) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);

    
    function balanceOfAt(address account, uint256 blockNo) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}


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
}


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
}


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
}


pragma solidity 0.8.4;

contract arShield {



    using SafeERC20 for IERC20;

    uint256 constant DENOMINATOR = 10000;
    
    bool public capped;
    bool public locked;
    uint256 public limit;
    address payable public beneficiary;
    address public depositor;
    uint256 public payoutAmt;
    uint256 public payoutBlock;
    uint256 public refTotal;
    uint256[] public feesToLiq;
    uint256[] public feePerBase;
    uint256 public totalTokens;

    mapping (address => uint256) public refBals;
    mapping (uint256 => mapping (address => uint256)) public paid;

    address public uTokenLink;
    IERC20 public pToken;
    IOracle public oracle;
    IArmorToken public arToken;
    ICovBase[] public covBases;
    IController public controller;

    event Unlocked(uint256 timestamp);
    event Locked(address reporter, uint256 timestamp);
    event HackConfirmed(uint256 payoutBlock, uint256 timestamp);
    event Mint(address indexed user, uint256 amount, uint256 timestamp);
    event Redemption(address indexed user, uint256 amount, uint256 timestamp);

    modifier onlyGov 
    {

        require(msg.sender == controller.governor(), "Only governance may call this function.");
        _;
    }

    modifier isLocked 
    {

        require(locked, "You may not do this while the contract is unlocked.");
        _;
    }

    modifier notLocked 
    {

        require(!locked, "You may not do this while the contract is locked.");
        _;
    }

    modifier withinLimits
    {

        _;
        uint256 _limit = limit;
        require(_limit == 0 || pToken.balanceOf( address(this) ) <= _limit, "Too much value in the shield.");
    }
    
    receive() external payable {}
    
    function initialize(
        address _oracle,
        address _pToken,
        address _arToken,
        address _uTokenLink, 
        uint256[] calldata _fees,
        address[] calldata _covBases
    )
      external
    {

        require(address(arToken) == address(0), "Contract already initialized.");

        uTokenLink = _uTokenLink;
        pToken = IERC20(_pToken);
        oracle = IOracle(_oracle);
        arToken = IArmorToken(_arToken);
        controller = IController(msg.sender);
        beneficiary = controller.beneficiary();

        require(_covBases.length == _fees.length, "Improper length array.");
        for(uint256 i = 0; i < _covBases.length; i++) {
            covBases.push( ICovBase(_covBases[i]) );
            feePerBase.push(_fees[i]);
            feesToLiq.push(0);
        }
    }

    function mint(
        uint256 _pAmount,
        address _referrer
    )
      external
      notLocked
      withinLimits
    {

        address user = msg.sender;

        (
         uint256 fee, 
         uint256 refFee, 
         uint256 totalFees,
         uint256[] memory newFees
        ) = _findFees(_pAmount);

        uint256 arAmount = arValue(_pAmount - fee);
        pToken.safeTransferFrom(user, address(this), _pAmount);
        _saveFees(newFees, _referrer, refFee);

        if (capped) {
            uint256 ethValue = getEthValue(pToken.balanceOf( address(this) ) - totalFees);
            require(checkCapped(ethValue), "Not enough coverage available.");

            for (uint256 i = 0; i < covBases.length; i++) covBases[i].updateShield(ethValue);
        }

        arToken.mint(user, arAmount);
        controller.emitAction(
            msg.sender, 
            _referrer, 
            address(this), 
            address(pToken),
            _pAmount,
            refFee,
            true
        );
        emit Mint(user, arAmount, block.timestamp);
    }

    function redeem(
        uint256 _arAmount,
        address _referrer
    )
      external
    {

        address user = msg.sender;
        uint256 pAmount = pValue(_arAmount);
        arToken.transferFrom(user, address(this), _arAmount);
        arToken.burn(_arAmount);
        
        (
         uint256 fee, 
         uint256 refFee,
         uint256 totalFees,
         uint256[] memory newFees
        ) = _findFees(pAmount);

        pToken.transfer(user, pAmount - fee);
        _saveFees(newFees, _referrer, refFee);

        uint256 ethValue = getEthValue(pToken.balanceOf( address(this) ) - totalFees);
        for (uint256 i = 0; i < covBases.length; i++) covBases[i].updateShield(ethValue);

        controller.emitAction(
            msg.sender, 
            _referrer, 
            address(this), 
            address(pToken),
            pAmount,
            refFee,
            false
        );
        emit Redemption(user, _arAmount, block.timestamp);
    }

    function liquidate(
        uint256 _covId
    )
      external
      payable
    {

        (
         uint256 ethOwed, 
         uint256 tokensOwed,
         uint256 tokenFees
        ) = liqAmts(_covId);
        require(msg.value <= ethOwed, "Too much Ether paid.");

        (
         uint256 tokensOut,
         uint256 feesPaid,
         uint256 ethValue
        ) = payAmts(
            msg.value,
            ethOwed,
            tokensOwed,
            tokenFees
        );

        covBases[_covId].updateShield{value:msg.value}(ethValue);
        feesToLiq[_covId] -= feesPaid;
        pToken.transfer(msg.sender, tokensOut);
    }

    function claim()
      external
      isLocked
    {

        uint256 balance = arToken.balanceOfAt(msg.sender, payoutBlock);
        uint256 owedBal = balance - paid[payoutBlock][msg.sender];
        uint256 amount = payoutAmt
                         * owedBal
                         / 1 ether;

        require(balance > 0 && amount > 0, "Sender did not have funds on payout block.");
        paid[payoutBlock][msg.sender] += owedBal;
        payable(msg.sender).transfer(amount);
    }

    function withdraw(
        address _user
    )
      external
    {

        uint256 balance = refBals[_user];
        refBals[_user] = 0;
        pToken.transfer(_user, balance);
    }

    function pValue(
        uint256 _arAmount
    )
      public
      view
    returns (
        uint256 pAmount
    )
    {

        uint256 totalSupply = arToken.totalSupply();
        if (totalSupply == 0) return _arAmount;

        pAmount = ( pToken.balanceOf( address(this) ) - totalFeeAmts() )
                  * _arAmount 
                  / totalSupply;
    }

    function arValue(
        uint256 _pAmount
    )
      public
      view
    returns (
        uint256 arAmount
    )
    {

        uint256 balance = pToken.balanceOf( address(this) );
        if (balance == 0) return _pAmount;

        arAmount = arToken.totalSupply()
                   * _pAmount 
                   / ( balance - totalFeeAmts() );
    }

    function liqAmts(
        uint256 _covId
    )
      public
      view
    returns(
        uint256 ethOwed,
        uint256 tokensOwed,
        uint256 tokenFees
    )
    {

        ethOwed = covBases[_covId].getShieldOwed( address(this) );
        if (ethOwed > 0) tokensOwed = oracle.getTokensOwed(ethOwed, address(pToken), uTokenLink);

        tokenFees = feesToLiq[_covId];
        require(tokensOwed + tokenFees > 0, "No fees are owed.");

        uint256 ethFees = ethOwed > 0 ?
                            ethOwed
                            * tokenFees
                            / tokensOwed
                          : getEthValue(tokenFees);
        ethOwed += ethFees;
        tokensOwed += tokenFees;

        uint256 liqBonus = tokensOwed 
                           * controller.bonus()
                           / DENOMINATOR;
        tokensOwed += liqBonus;
    }

    function payAmts(
        uint256 _ethIn,
        uint256 _ethOwed,
        uint256 _tokensOwed,
        uint256 _tokenFees
    )
      public
      view
    returns(
        uint256 tokensOut,
        uint256 feesPaid,
        uint256 ethValue
    )
    {

        tokensOut = _ethIn
                    * _tokensOwed
                    / _ethOwed;

        feesPaid = _ethIn
                   * _tokenFees
                   / _ethOwed;

        ethValue = (pToken.balanceOf( address(this) ) 
                    - totalFeeAmts())
                   * _ethOwed
                   / _tokensOwed;
    }

    function totalFeeAmts()
      public
      view
    returns(
        uint256 totalOwed
    )
    {

        for (uint256 i = 0; i < covBases.length; i++) {
            uint256 ethOwed = covBases[i].getShieldOwed( address(this) );
            if (ethOwed > 0) totalOwed += oracle.getTokensOwed(ethOwed, address(pToken), uTokenLink);
            totalOwed += feesToLiq[i];
        }

        totalOwed += refTotal;
    }

    function checkCapped(
        uint256 _ethValue
    )
      public
      view
    returns(
        bool allowed
    )
    {

        if (capped) {
            for(uint256 i = 0; i < covBases.length; i++) {
                if( !covBases[i].checkCoverage(_ethValue) ) return false;
            }
        }
        allowed = true;
    }

    function getEthValue(
        uint256 _pAmount
    )
      public
      view
    returns(
        uint256 ethValue
    )
    {

        ethValue = oracle.getEthOwed(_pAmount, address(pToken), uTokenLink);
    }

    function findFeePct()
      external
      view
    returns(
        uint256 percent
    )
    {

        uint256 end = feePerBase.length;
        for (uint256 i = 0; i < end; i++) percent += feePerBase[i];
        percent += controller.refFee();
    }

    function _findFees(
        uint256 _pAmount
    )
      internal
      view
    returns(
        uint256 userFee,
        uint256 refFee,
        uint256 totalFees,
        uint256[] memory newFees
    )
    {

        newFees = feesToLiq;
        for (uint256 i = 0; i < newFees.length; i++) {
            totalFees += newFees[i];
            uint256 fee = _pAmount
                          * feePerBase[i]
                          / DENOMINATOR;
            newFees[i] += fee;
            userFee += fee;
        }

        refFee = _pAmount 
                 * controller.refFee() 
                 / DENOMINATOR;
        userFee += refFee;


        totalFees += userFee + refTotal;
    }

    function _saveFees(
        uint256[] memory liqFees,
        address _referrer,
        uint256 _refFee
    )
      internal
    {

        refTotal += _refFee;
        if ( _referrer != address(0) ) refBals[_referrer] += _refFee;
        else refBals[beneficiary] += _refFee;
        for (uint256 i = 0; i < liqFees.length; i++) feesToLiq[i] = liqFees[i];
    }
    
    function notifyHack()
      external
      payable
      notLocked
    {

        require(msg.value == controller.depositAmt(), "You must pay the deposit amount to notify a hack.");
        depositor = msg.sender;
        locked = true;
        emit Locked(msg.sender, block.timestamp);
    }
    
    function confirmHack(
        uint256 _payoutBlock,
        uint256 _payoutAmt
    )
      external
      isLocked
      onlyGov
    {

        payable(depositor).call{value: controller.depositAmt()}("");
        delete depositor;
        payoutBlock = _payoutBlock;
        payoutAmt = _payoutAmt;
        emit HackConfirmed(_payoutBlock, block.timestamp);
    }
    
    function unlock()
      external
      isLocked
      onlyGov
    {

        locked = false;
        delete payoutBlock;
        delete payoutAmt;
        emit Unlocked(block.timestamp);
    }

    function withdrawExcess(address _token)
      external
      notLocked
    {

        if ( _token == address(0) ) beneficiary.transfer( address(this).balance );
        else if ( _token != address(pToken) ) {
            IERC20(_token).transfer( beneficiary, IERC20(_token).balanceOf( address(this) ) );
        }
    }

    function banPayouts(
        uint256 _payoutBlock,
        address[] calldata _users,
        uint256[] calldata _amounts
    )
      external
      onlyGov
    {

        for (uint256 i = 0; i < _users.length; i++) paid[_payoutBlock][_users[i]] += _amounts[i];
    }

    function changeFees(
        uint256[] calldata _newFees
    )
      external
      onlyGov
    {

        require(_newFees.length == feePerBase.length, "Improper fees length.");
        for (uint256 i = 0; i < _newFees.length; i++) feePerBase[i] = _newFees[i];
    }

    function changeBeneficiary(
        address payable _beneficiary
    )
      external
      onlyGov
    {

        beneficiary = _beneficiary;
    }

    function changeCapped(
        bool _capped
    )
      external
      onlyGov
    {

        capped = _capped;
    }

    function changeLimit(
        uint256 _limit
    )
      external
      onlyGov
    {

        limit = _limit;
    }

    function cancelCoverage(
        uint256 _covId
    )
      external
      onlyGov
    {

        covBases[_covId].updateShield(0);
    }

}