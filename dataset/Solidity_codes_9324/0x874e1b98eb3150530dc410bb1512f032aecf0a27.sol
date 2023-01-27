
pragma solidity ^0.7.4;

library SafeMath {

    function addSafe(uint _a, uint _b) internal pure returns (uint c) {

        c = _a + _b;
        require(c >= _a);
    }
    function subSafe(uint _a, uint _b) internal pure returns (uint c) {

        require(_b <= _a, "Insufficient balance");
        c = _a - _b;
    }
    function mulSafe(uint _a, uint _b) internal pure returns (uint c) {

        c = _a * _b;
        require(_a == 0 || c / _a == _b);
    }
    function divSafe(uint _a, uint _b) internal pure returns (uint c) {

        require(_b > 0);
        c = _a / _b;
    }
}


interface ERC20Interface {

    function totalSupply() external view returns (uint);

    function balanceOf(address _tokenOwner) external view returns (uint);

    function allowance(address _tokenOwner, address _spender) external view returns (uint);

    function transfer(address _to, uint _amount) external returns (bool);

    function approve(address _spender, uint _amount) external returns (bool);

    function transferFrom(address _from, address _to, uint _amount) external returns (bool);

}

interface ApproveAndCallFallBack {

    function receiveApproval(address _tokenOwner, uint256 _amount, address _tokenContract, bytes memory _data) external;

}

interface SettlementInterface {

    function disburseCommissions(bool _disburseBackstop) external;

}


interface ERC20_USDT {

    function totalSupply() external view returns (uint);

    function balanceOf(address who) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function transfer(address to, uint value) external;

    function approve(address spender, uint value) external;

    function transferFrom(address from, address to, uint value) external;

}


contract Owned {

    address public owner;
    address public newOwner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;
    }
    function acceptOwnership() public {

        require(msg.sender == newOwner);
        owner = newOwner;
        newOwner = address(0);
        emit OwnershipTransferred(owner, newOwner);
    }

    event OwnershipTransferred(address indexed _from, address indexed _to);
}


contract YieldTokenService is ApproveAndCallFallBack, SettlementInterface, Owned {

    using SafeMath for uint;

    address public constant USDTContract = 0xdAC17F958D2ee523a2206206994597C13D831ec7;      // USDT contract
    address public constant BXTBContract = 0x7bA9caa5D19002618F1D93e691490377361D5E60;      // BXTB contract
    address public constant yieldTokenContract = 0x39dCCA7984B22cCB0347DeEAeEaaEE6e6Ce9ba9F;     // yBXTB contract
    address public constant CHIPContract = 0x73F737dE96cF8987CA2C4C1FDC5134688BB2e10f;      // CHIP contract

    address public bxtbFoundation = 0x616143B2e9ADC2F48c9Ad4C30162e0782297f06f;
    address public recoveryAdmin;
    address public settlementAdmin;
    address public backstopAdmin;

    uint public totalPoolUSDTCollateral;
    uint public totalPoolBXTB;

    uint public totalPoolCHIPBackStop;
    uint public totalPoolCHIPBackStopAvailable;

    uint public totalPoolCHIPCommissions;
    uint public totalPoolCHIPCommissionsAvailable;

    uint public totalSupplyYieldToken;
    uint public outstandingYieldToken;

    uint public totalSupplyCHIP;
    uint public outstandingCHIP;

    uint public constant decimals = 6;
    uint public collateralizationRatio;

    uint public bxtbTokenRatio;

    bool public allowStaking;
    bool public allowCommissions;

    constructor() {
        bxtbTokenRatio = 100;           // 100%
        collateralizationRatio = 100;   // 100%

        allowStaking = true;
        allowCommissions = false;
    }

    event TotalSupplyYieldTokenChanged(uint _amount);                   // Load YieldToken supply
    event TotalSupplyCHIPChanged(uint _amount);                         // Load CHIP supply
    event OutstandingSupplyChanged();                                   // Change in YieldToken & CHIP in circulation
    event ChangeBxtbTokenRatio(uint _amount);                           // Token ratio changed
    event CommissionReceived(address indexed _sender, uint _amount);    // Commissions received
    event CommissionsDisbursed(uint _amount);
    event BackstopDisbursed(uint _amount);
    event BackstopAdjusted(bool _refunded, uint _amount);


    function receiveApproval(address _tokenOwner, uint256 _amount, address _tokenContract, bytes memory _data) public override {

        require((msg.data.length == (6 * 32) + 4) && (_data.length == 1), "Input length error");

        require(msg.sender == yieldTokenContract ||
        msg.sender == CHIPContract ||
        msg.sender == BXTBContract, "Unknown caller");

        uint8 mode = uint8(_data[0]);
        require(mode == 0x10 || mode == 0xE0 || mode == 0xF0, "Mode not accepted");

        if(mode == 0x10) {
            require(totalSupplyYieldToken == totalSupplyCHIP, "Supply imbalance");
            uint wildChip;

            if(msg.sender == BXTBContract) {
                require(allowStaking == true, "Staking is paused");

                uint allowanceUsdt = ERC20_USDT(USDTContract).allowance(_tokenOwner, address(this));
                uint allowanceBxtb = _amount;

                if(bxtbTokenRatio == 100) {  // 100 percent
                    if(allowanceUsdt <= allowanceBxtb) allowanceBxtb = allowanceUsdt;
                    else allowanceUsdt = allowanceBxtb;
                }
                else {
                    if(bxtbTokenRatio > 0) {
                        uint allowanceBxtbExpected = allowanceUsdt.mulSafe(bxtbTokenRatio).divSafe(100);
                        if(allowanceBxtb >= allowanceBxtbExpected) allowanceBxtb = allowanceBxtbExpected;  // Sufficient BXTB
                        else allowanceUsdt = allowanceBxtb.mulSafe(100).divSafe(bxtbTokenRatio);  // Reduce USDT due to insufficient BXTB
                    }
                    else allowanceBxtb = 0;  // Prevent divide-by-zero errors
                }

                require(allowanceUsdt > 0, "Zero stake");

                uint remainderYieldToken = totalSupplyYieldToken.subSafe(outstandingYieldToken);
                require((allowanceUsdt <= remainderYieldToken) && (remainderYieldToken > 0), "Staking size exceeded");

                ERC20_USDT(USDTContract).transferFrom(_tokenOwner, address(this), allowanceUsdt);

                totalPoolUSDTCollateral = totalPoolUSDTCollateral.addSafe(allowanceUsdt);

                emit OutstandingSupplyChanged();

                if(allowanceBxtb > 0) {
                    ERC20Interface(BXTBContract).transferFrom(_tokenOwner, address(this), allowanceBxtb);
                    totalPoolBXTB = totalPoolBXTB.addSafe(allowanceBxtb);
                }

                outstandingYieldToken = outstandingYieldToken.addSafe(allowanceUsdt);
                outstandingCHIP = outstandingCHIP.addSafe(allowanceUsdt);

                ERC20Interface(yieldTokenContract).transfer(_tokenOwner, allowanceUsdt);
                ERC20Interface(CHIPContract).transfer(_tokenOwner, allowanceUsdt);

                wildChip = outstandingCHIP.subSafe(totalPoolCHIPBackStop);
                if(wildChip > 0) collateralizationRatio = totalPoolUSDTCollateral.mulSafe(100).divSafe(wildChip);  // In percent
                else collateralizationRatio = 100;
            }
            else if(msg.sender == CHIPContract) {
                uint allowanceYieldToken = ERC20Interface(yieldTokenContract).allowance(_tokenOwner, address(this));
                uint allowanceCHIP = _amount;

                uint allowanceSize;
                if(allowanceYieldToken <= allowanceCHIP) allowanceSize = allowanceYieldToken;
                else allowanceSize = allowanceCHIP;

                require(allowanceSize > 0, "Zero redeem");

                require((allowanceSize <= outstandingCHIP) && (outstandingCHIP > 0), "Redemption size exceeded");

                ERC20Interface(yieldTokenContract).transferFrom(_tokenOwner, address(this), allowanceSize);
                ERC20Interface(CHIPContract).transferFrom(_tokenOwner, address(this), allowanceSize);

                outstandingYieldToken = outstandingYieldToken.subSafe(allowanceSize);
                outstandingCHIP = outstandingCHIP.subSafe(allowanceSize);

                emit OutstandingSupplyChanged();

                uint shareOfBxtb;

                if(outstandingCHIP > 0) {
                    totalPoolUSDTCollateral = totalPoolUSDTCollateral.subSafe(allowanceSize);
                    ERC20_USDT(USDTContract).transfer(_tokenOwner, allowanceSize);

                    if(bxtbTokenRatio == 100) shareOfBxtb = allowanceSize;  // 100 percent
                    else shareOfBxtb = allowanceSize.mulSafe(bxtbTokenRatio).divSafe(100);

                    if(shareOfBxtb > totalPoolBXTB) shareOfBxtb = totalPoolBXTB;

                    totalPoolBXTB = totalPoolBXTB.subSafe(shareOfBxtb);
                    ERC20Interface(BXTBContract).transfer(bxtbFoundation, shareOfBxtb);

                    wildChip = outstandingCHIP.subSafe(totalPoolCHIPBackStop);
                    if(wildChip > 0) collateralizationRatio = totalPoolUSDTCollateral.mulSafe(100).divSafe(wildChip);  // In percent
                    else collateralizationRatio = 100;
                }
                else {
                    outstandingCHIP = 0;
                    outstandingYieldToken = 0;

                    totalPoolUSDTCollateral = 0;
                    uint residualValue = ERC20_USDT(USDTContract).balanceOf(address(this));
                    ERC20_USDT(USDTContract).transfer(_tokenOwner, residualValue);

                    totalPoolBXTB = 0;
                    shareOfBxtb = ERC20Interface(BXTBContract).balanceOf(address(this));
                    ERC20Interface(BXTBContract).transfer(bxtbFoundation, shareOfBxtb);

                    collateralizationRatio = 100;
                }
            }
            else revert("Unknown stake/redeem token");
        }
        else if(mode == 0xE0) {
            require(msg.sender == CHIPContract, "Only CHIP accepted");
            payCommission(_tokenOwner);
        }
        else if(mode == 0xF0) {
            require((_tokenOwner == owner) && (owner != address(0)), "Caller must be owner");
            require(_amount > 0, "Zero deposit");

            if(msg.sender == yieldTokenContract) {
                ERC20Interface(yieldTokenContract).transferFrom(_tokenOwner, address(this), _amount);
                totalSupplyYieldToken = totalSupplyYieldToken.addSafe(_amount);
                emit TotalSupplyYieldTokenChanged(totalSupplyYieldToken);
            }
            else if(msg.sender == CHIPContract) {
                ERC20Interface(CHIPContract).transferFrom(_tokenOwner, address(this), _amount);
                totalSupplyCHIP = totalSupplyCHIP.addSafe(_amount);
                emit TotalSupplyCHIPChanged(totalSupplyCHIP);
            }
            else revert("Unknown reserve token");
        }
    }

    function payCommission(address _sender) internal {

        require(allowCommissions == true, "Commissions paused");

        uint allowanceCHIP = ERC20Interface(CHIPContract).allowance(_sender, address(this));
        require(allowanceCHIP > 0, "Zero commission");

        if(outstandingYieldToken > 0) {
            ERC20Interface(CHIPContract).transferFrom(_sender, address(this), allowanceCHIP);
            distributeToPools(allowanceCHIP);
            emit CommissionReceived(_sender, allowanceCHIP);
        }
        else {
            address recipient;
            if(owner != address(0)) recipient = owner;  // Send to contract owner
            else if(settlementAdmin != address(0)) recipient = settlementAdmin;  // If no contract owner, send to Settlement Admin
            else if(bxtbFoundation != address(0)) recipient = bxtbFoundation;  // If no contract owner, send to BXTB Foundation
            else revert("No recipients");  // No foundation, decline commission

            ERC20Interface(CHIPContract).transferFrom(_sender, recipient, allowanceCHIP);
            emit CommissionReceived(_sender, allowanceCHIP);
        }
    }

    function distributeToPools(uint _amount) internal {

        require(outstandingYieldToken > 0, "No more unit holders");

        uint backstopShortfall;
        uint backstopTarget = totalPoolUSDTCollateral.divSafe(10);  // Target backstop to be 10% of collateral

        if(totalPoolCHIPBackStop < backstopTarget) backstopShortfall = backstopTarget.subSafe(totalPoolCHIPBackStop);

        if(backstopShortfall > 0) {
            uint allocateBackstop = _amount.divSafe(6);  // 1/6th goes to backstop pool

            if(allocateBackstop > backstopShortfall) allocateBackstop = backstopShortfall;  // Limit reached

            uint allocateCommission = _amount.subSafe(allocateBackstop);

            totalPoolCHIPBackStop = totalPoolCHIPBackStop.addSafe(allocateBackstop);                    // Cumulative amount deposited
            totalPoolCHIPBackStopAvailable = totalPoolCHIPBackStopAvailable.addSafe(allocateBackstop);  // Current balance in contract

            totalPoolCHIPCommissions = totalPoolCHIPCommissions.addSafe(allocateCommission);                    // Cumulative amount deposited
            totalPoolCHIPCommissionsAvailable = totalPoolCHIPCommissionsAvailable.addSafe(allocateCommission);  // Current balance in contract
        }
        else {
            totalPoolCHIPCommissions = totalPoolCHIPCommissions.addSafe(_amount);                       // Cumulative amount deposited
            totalPoolCHIPCommissionsAvailable = totalPoolCHIPCommissionsAvailable.addSafe(_amount);     // Current balance in contract
        }

        uint wildChip = outstandingCHIP.subSafe(totalPoolCHIPBackStop);
        if(wildChip > 0) collateralizationRatio = totalPoolUSDTCollateral.mulSafe(100).divSafe(wildChip);  // In percent
        else collateralizationRatio = 100;
    }

    function disburseCommissions(bool _disburseBackstop) external override {

        require((msg.sender == yieldTokenContract) ||
        (msg.sender == settlementAdmin) ||
            (msg.sender == owner) , "Caller not authorized");

        require(settlementAdmin != address(0), "Settlement Admin address error");

        uint withdrawAmount = totalPoolCHIPCommissionsAvailable;
        totalPoolCHIPCommissionsAvailable = 0;
        ERC20Interface(CHIPContract).transfer(settlementAdmin, withdrawAmount);
        emit CommissionsDisbursed(withdrawAmount);

        if(_disburseBackstop == true) {
            require(backstopAdmin != address(0), "Backstop Admin address error");

            withdrawAmount = totalPoolCHIPBackStopAvailable;
            totalPoolCHIPBackStopAvailable = 0;
            ERC20Interface(CHIPContract).transfer(backstopAdmin, withdrawAmount);
            emit BackstopDisbursed(withdrawAmount);
        }
    }

    function disburseBackstop() external {

        require((msg.sender == backstopAdmin) || (msg.sender == owner), "Caller not authorized");
        require(backstopAdmin != address(0), "Backstop Admin address error");

        uint withdrawAmount = totalPoolCHIPBackStopAvailable;
        totalPoolCHIPBackStopAvailable = 0;
        ERC20Interface(CHIPContract).transfer(backstopAdmin, withdrawAmount);
        emit BackstopDisbursed(withdrawAmount);
    }

    function adjustBackstop(bool _refunded, uint _amount) external {

        require((msg.sender == backstopAdmin) || (msg.sender == owner), "Caller not authorized");

        if(_refunded == true) totalPoolCHIPBackStop = totalPoolCHIPBackStop.subSafe(_amount);  // Back out refunded amount
        else totalPoolCHIPBackStop = totalPoolCHIPBackStop.addSafe(_amount);  // Add more. This is used to fix user errors

        uint wildChip = outstandingCHIP.subSafe(totalPoolCHIPBackStop);
        if(wildChip > 0) collateralizationRatio = totalPoolUSDTCollateral.mulSafe(100).divSafe(wildChip);  // In percent
        else collateralizationRatio = 100;

        emit BackstopAdjusted(_refunded, _amount);
    }

    function changeRecoveryAdmin(address _newAddress) external {

        require(msg.data.length == 32 + 4, "Address error");  // Prevent input error
        require((msg.sender == recoveryAdmin) || (msg.sender == owner), "Caller not authorized");
        recoveryAdmin = _newAddress;
    }

    function changeSettlementAdmin(address _newAddress) external {

        require(msg.data.length == 32 + 4, "Address error");  // Prevent input error
        require((msg.sender == settlementAdmin) || (msg.sender == owner), "Caller not authorized");
        settlementAdmin = _newAddress;
    }

    function changeBackstopAdmin(address _newAddress) external {

        require(msg.data.length == 32 + 4, "Address error");  // Prevent input error
        require((msg.sender == backstopAdmin) || (msg.sender == owner), "Caller not authorized");
        backstopAdmin = _newAddress;
    }

    function changeBxtbFoundation(address _newAddress) external {

        require(msg.data.length == 32 + 4, "Address error");  // Prevent input error
        require(msg.sender == bxtbFoundation, "Caller not authorized");
        bxtbFoundation = _newAddress;
    }

    function changebxtbTokenRatio(uint _newRatio) external {

        require(msg.sender == bxtbFoundation, "Caller not authorized");
        bxtbTokenRatio = _newRatio;
        emit ChangeBxtbTokenRatio(_newRatio);
    }

    function setAllowStaking(bool _allow) external onlyOwner {

        allowStaking = _allow;
    }

    function setAllowCommissions(bool _allow) external onlyOwner {

        allowCommissions = _allow;
    }

    function recoverLostCoins(uint _amount, address _fromTokenContract, address _recoveryAddress) external {

        require(msg.data.length == (3 * 32) + 4, "Input length error");

        bool hasAdmin;
        if(recoveryAdmin != address(0)) {
            if(msg.sender == recoveryAdmin) {
                hasAdmin = true;
            }
            else if(_fromTokenContract == BXTBContract) {
                if(bxtbFoundation != address(0)) {
                    if(msg.sender != bxtbFoundation) revert("Caller must be admin");
                }
                else revert("Caller must be admin");
            }
            else revert("Caller must be admin");
        }

        if(_fromTokenContract == USDTContract) recoverLostUSDT(_amount, _fromTokenContract, _recoveryAddress, msg.sender, hasAdmin);
        else if(_fromTokenContract == BXTBContract) recoverLostBXTB(_amount, _fromTokenContract, _recoveryAddress, msg.sender, hasAdmin);
        else recoverLostERC20(_amount, _fromTokenContract, _recoveryAddress, msg.sender, hasAdmin);
    }

    function recoverLostUSDT(uint _amount, address _fromTokenContract, address _recoveryAddress, address _sender, bool _hasAdmin) internal {

        uint amountAdmin;
        uint amountOwner;
        uint amountRecoveryAddress;
        uint amountSender;

        uint sweepAmount;
        uint recoverAmount;

        sweepAmount = ERC20_USDT(_fromTokenContract).balanceOf(address(this));
        if(sweepAmount > totalPoolUSDTCollateral) {
            sweepAmount = sweepAmount.subSafe(totalPoolUSDTCollateral);

            if(_amount <= sweepAmount) {
                recoverAmount = _amount.mulSafe(3).divSafe(4);
                sweepAmount = sweepAmount.subSafe(recoverAmount);
            }

            if(_hasAdmin) {
                amountAdmin = sweepAmount;

                if(_recoveryAddress != address(0)) amountRecoveryAddress = recoverAmount;
                else amountAdmin = amountAdmin.addSafe(recoverAmount);
            }
            else {
                amountOwner = sweepAmount;

                if(_recoveryAddress != address(0)) amountRecoveryAddress = recoverAmount;
                else amountSender = recoverAmount;
            }

            if(amountAdmin > 0) ERC20_USDT(_fromTokenContract).transfer(recoveryAdmin, amountAdmin);
            if(amountOwner > 0) ERC20_USDT(_fromTokenContract).transfer(owner, amountOwner);
            if(amountRecoveryAddress > 0) ERC20_USDT(_fromTokenContract).transfer(_recoveryAddress, amountRecoveryAddress);
            if(amountSender > 0) ERC20_USDT(_fromTokenContract).transfer(_sender, amountSender);
        }
    }

    function recoverLostBXTB(uint _amount, address _fromTokenContract, address _recoveryAddress, address _sender, bool _hasAdmin) internal {

        uint amountAdmin;
        uint amountFoundation;
        uint amountRecoveryAddress;
        uint amountSender;

        uint sweepAmount;
        uint recoverAmount;

        sweepAmount = ERC20Interface(_fromTokenContract).balanceOf(address(this));
        if(sweepAmount > totalPoolBXTB) {
            sweepAmount = sweepAmount.subSafe(totalPoolBXTB);

            if(_amount <= sweepAmount) {
                recoverAmount = _amount.mulSafe(3).divSafe(4);
                sweepAmount = sweepAmount.subSafe(recoverAmount);
            }

            if(_hasAdmin) {
                if(bxtbFoundation != address(0)) amountFoundation = sweepAmount;
                else amountAdmin = sweepAmount;
                if(_recoveryAddress != address(0)) amountRecoveryAddress = recoverAmount;
                else amountAdmin = amountAdmin.addSafe(recoverAmount);
            }
            else {
                if(bxtbFoundation != address(0)) amountFoundation = sweepAmount;
                else if(_recoveryAddress != address(0)) amountRecoveryAddress = sweepAmount;
                else amountSender = sweepAmount;

                if(_recoveryAddress != address(0)) amountRecoveryAddress = amountRecoveryAddress.addSafe(recoverAmount);
                else amountSender = amountSender.addSafe(recoverAmount);
            }

            if(amountAdmin > 0) ERC20Interface(_fromTokenContract).transfer(recoveryAdmin, amountAdmin);
            if(amountFoundation > 0) ERC20Interface(_fromTokenContract).transfer(bxtbFoundation, amountFoundation);
            if(amountRecoveryAddress > 0) ERC20Interface(_fromTokenContract).transfer(_recoveryAddress, amountRecoveryAddress);
            if(amountSender > 0) ERC20Interface(_fromTokenContract).transfer(_sender, amountSender);
        }
    }

    function recoverLostERC20(uint _amount, address _fromTokenContract, address _recoveryAddress, address _sender, bool _hasAdmin) internal {

        uint amountAdmin;
        uint amountOwner;
        uint amountRecoveryAddress;
        uint amountSender;

        uint sweepAmount;
        uint recoverAmount;
        uint poolSize;

        sweepAmount = ERC20Interface(_fromTokenContract).balanceOf(address(this));

        if(_fromTokenContract == yieldTokenContract) poolSize = outstandingYieldToken;
        else if(_fromTokenContract == CHIPContract) poolSize = outstandingCHIP;
        else poolSize = 0;

        if(sweepAmount > poolSize) {
            sweepAmount = sweepAmount.subSafe(poolSize);

            if(_amount <= sweepAmount) {
                recoverAmount = _amount.mulSafe(3).divSafe(4);
                sweepAmount = sweepAmount.subSafe(recoverAmount);
            }

            if(_hasAdmin) {
                amountAdmin = sweepAmount;

                if(_recoveryAddress != address(0)) amountRecoveryAddress = recoverAmount;
                else amountAdmin = amountAdmin.addSafe(recoverAmount);
            }
            else {
                amountOwner = sweepAmount;

                if(_recoveryAddress != address(0)) amountRecoveryAddress = recoverAmount;
                else amountSender = recoverAmount;
            }

            if(amountAdmin > 0) ERC20Interface(_fromTokenContract).transfer(recoveryAdmin, amountAdmin);
            if(amountOwner > 0) ERC20Interface(_fromTokenContract).transfer(owner, amountOwner);
            if(amountRecoveryAddress > 0) ERC20Interface(_fromTokenContract).transfer(_recoveryAddress, amountRecoveryAddress);
            if(amountSender > 0) ERC20Interface(_fromTokenContract).transfer(_sender, amountSender);
        }
    }

}