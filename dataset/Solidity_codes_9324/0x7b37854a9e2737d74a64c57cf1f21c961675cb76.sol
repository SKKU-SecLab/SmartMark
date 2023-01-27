pragma solidity ^0.5.12;

interface Token {

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool ok);

}

contract TokenEscrow {


    address public tcjContractor;
    address public xraContractor;
    address public tcjToken;
    address public xraToken;
    uint256 public tcjRequiredAmount;
    uint256 public xraRequiredAmount;
    uint256 public depositDueDate;
    uint256 public withdrawalStartDate;
    bool public xraReceded;
    bool public tcjReceded;

    event TokensWithdrawn(address indexed beneficiary,address indexed token, uint256 indexed amount);
    event ContractReceded(address indexed contractor, bool indexed contractReceded);

    constructor(address _tcj_contractor,
                address _xra_contractor,
                address _tcjToken,
                address _xraToken,
                uint256 _tcjRequiredAmount,
                uint256 _xraRequiredAmount,
                uint256 _depositDueDate,
                uint256 _withdrawalStartDate) public {
        require(_tcjToken != address(0));
        require(_xraToken != address(0));
        require(_tcj_contractor != address(0));
        require(_xra_contractor != address(0));
        require(_tcjRequiredAmount > 0);
        require(_xraRequiredAmount > 0);
        require(_depositDueDate >= block.timestamp && _withdrawalStartDate > _depositDueDate);

        tcjToken = _tcjToken;
        xraToken = _xraToken;
        tcjContractor = _tcj_contractor;
        xraContractor = _xra_contractor;
        tcjRequiredAmount = _tcjRequiredAmount;
        xraRequiredAmount = _xraRequiredAmount;
        depositDueDate = _depositDueDate;
        withdrawalStartDate = _withdrawalStartDate;
    }

    function () external payable {
        require(msg.sender == xraContractor || msg.sender == tcjContractor);
        require(msg.value == 0);
        if (msg.sender == xraContractor) {
            processWithdrawFromSender(msg.sender,Token(xraToken),xraRequiredAmount,Token(tcjToken),tcjRequiredAmount);
        } else if(msg.sender == tcjContractor) {
            processWithdrawFromSender(msg.sender,Token(tcjToken),tcjRequiredAmount, Token(xraToken),xraRequiredAmount);
        }
    }

    function contractReceded() public view returns (bool) {

        return tcjReceded && xraReceded;
    }

    function recede() external {

        require(msg.sender == xraContractor || msg.sender == tcjContractor,
            "Sender not allowed to operate on the contract");
        if (msg.sender == xraContractor && !xraReceded) {
            xraReceded = true;
            emit ContractReceded(msg.sender, xraReceded && tcjReceded);
        } else if (msg.sender == tcjContractor && !tcjReceded) {
            tcjReceded = true;
            emit ContractReceded(msg.sender, xraReceded && tcjReceded);
        } else {
            revert("Already receded");
        }
    }


    function processWithdrawFromSender(address contractor, Token contractorToken,uint256 requiredDeposit, Token counterpartToken, uint256 counterpartExpectedDeposit) private {

        if (contractReceded()) {
            bool ok = withdrawAllTokens(contractor,contractorToken);
            if (!ok) {
                revert("No tokens have been deposited by the sender");
            }
            return;
        }

        uint256 contractorTokenBalance = contractorToken.balanceOf(address(this));
        uint256 counterPartTokenBalance = counterpartToken.balanceOf(address(this));
        uint256 timestamp = block.timestamp;


        if (timestamp < depositDueDate) {
            bool ok = withdrawExcessTokens(contractor,contractorToken,requiredDeposit);
            if (!ok) {
                revert("There is no excess deposit");
            }

        } else if (timestamp >= depositDueDate && timestamp < withdrawalStartDate) {
            if (contractorTokenBalance >= requiredDeposit &&
                counterPartTokenBalance >= counterpartExpectedDeposit) {
                bool ok = withdrawExcessTokens(contractor,contractorToken,requiredDeposit);
                if (!ok) {
                    revert("There is no excess deposit");
                }

            } else {
                bool ok = withdrawAllTokens(contractor,contractorToken);
                if (!ok) {
                    revert("No tokens have been deposited ");
                }
            }
        } else if (timestamp >= withdrawalStartDate) {
            if (contractorTokenBalance >= requiredDeposit &&
                counterPartTokenBalance >= counterpartExpectedDeposit) {
                bool excessOk = withdrawExcessTokens(contractor,contractorToken,requiredDeposit);
                bool withdrawOk = withdrawTokens(contractor,counterpartToken,counterpartExpectedDeposit);

                if (!excessOk && !withdrawOk) {
                    revert("No  excess tokens have been deposited and tokens of the counterpart have already been withdrawn");
                }
            } else {
                bool ok = withdrawAllTokens(contractor,contractorToken);
                if (!ok) {
                    revert("There is no excess deposit");
                }
            }
        }

    }

    function withdrawTokens(address contractor, Token token, uint256 amount) private returns (bool success){

        uint256 balance = token.balanceOf(address(this));
        if (balance>=amount) {
            token.transfer(contractor,amount);
            emit TokensWithdrawn(contractor,address(token),amount);
            return true;
        } else {
            return false;
        }
    }

    function withdrawAllTokens(address contractor, Token token) private returns (bool success)  {

        uint256 actualDeposit = token.balanceOf(address(this));
        if (actualDeposit>0) {
            token.transfer(contractor,actualDeposit);
            emit TokensWithdrawn(contractor,address(token),actualDeposit);
            return true;
        } else {
            return false;
        }
    }

    function withdrawExcessTokens(address contractor,Token token, uint256 requiredDeposit) private returns (bool success) {

        uint256 actualDeposit = token.balanceOf(address(this));
        if (actualDeposit > requiredDeposit) {
            uint256 amount = actualDeposit - requiredDeposit;
            token.transfer(contractor,amount);
            emit TokensWithdrawn(contractor,address(token),amount);
            return true;
        } else {
            return false;
        }
    }


    function tokenFallback(address from, uint256 value, bytes memory data) public {

    }


}pragma solidity ^0.5.12;


contract TcjXraTest is TokenEscrow(
    0xC9d32Ab70a7781a128692e9B4FecEBcA6C1Bcce4,
    0x98719cFC0AeE5De1fF30bB5f22Ae3c2Ce45e43F7,
    0x44744e3e608D1243F55008b328fE1b09bd42E4Cc,
    0x7025baB2EC90410de37F488d1298204cd4D6b29d,
    10000000000000000000,
    10000000000000000000,
    1572393600,
    1572451200) {

    constructor() public{

    }
}
