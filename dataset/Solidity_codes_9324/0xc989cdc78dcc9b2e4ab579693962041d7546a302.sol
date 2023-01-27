
pragma solidity ^0.4.25;

contract RocketCash
{

    uint constant public start = 1541678400;// The time Rocket.cash will start working (Thu Nov 08 2018 12:00:00 UTC)
    address constant public administrationFund = 0x4A04A4E5A15db1e57ADd4E93F3024DF214eC2f2F;// For advertising (13%) and support (2%)
    mapping (address => uint) public invested;// Investors and their investments
    mapping (address => uint) private lastInvestmentTime;// Last investment time for each investor
    mapping (address => uint) private collected;// Collected amounts for each investor
    mapping (address => Refer[]) public referrers;// Referrers for each investor (for statistics)
    mapping (address => Refer[]) public referrals;// Referrals for each investor (for statistics)
    uint public investedTotal;// Invested sum (for statistics)
    uint public investorsCount;// Investors count (for statistics)

    struct Refer// Structure for referrals (for statistics)
    {
        address investor;// Address of an investor of the project (referral)
        uint time;// Time of a transaction
        uint amount;// Amount of the transaction
        uint percent;// Percent given to a referrer
    }

    event investment(address addr, uint amount, uint invested, address referrer);// Investment event (for statistics)
    event withdraw(address addr, uint amount, uint invested);// Withdraw event (for statistics)

    function () external payable// This function has called every time someone makes a transaction to the Rocket.cash
    {
        if (msg.value > 0 ether)// If the sent value of ether is more than 0 - this is an investment
        {
            address referrer = _bytesToAddress(msg.data);// Get referrer from the "Data" field

            if (invested[referrer] > 0 && referrer != msg.sender)// If the referrer is an investor of the Rocket.cash and the referrer is not the current investor (you can't be the referrer for yourself)
            {
                uint referrerBonus = msg.value * 10 / 100;// Calculate bonus for the referrer (10%)
                uint referralBonus = msg.value * 3 / 100;// Calculate cash back bonus for the investor (3%)

                collected[referrer]   += referrerBonus;// Add bonus to the referrer
                collected[msg.sender] += referralBonus;// Add cash back bonus to the investor

                referrers[msg.sender].push(Refer(referrer, now, msg.value, referralBonus));// Save the referrer for the referral (for statistics)
                referrals[referrer].push(Refer(msg.sender, now, msg.value, referrerBonus));// Save the referral for the referrer (for statistics)
            }

            if (start < now)// If the project has started
            {
                if (invested[msg.sender] != 0) // If the investor has already invested to the Rocket.cash
                {
                    collected[msg.sender] = availableDividends(msg.sender);// Calculate dividends of the investor and remember it
                }

                lastInvestmentTime[msg.sender] = now;// Save the last investment time for the investor
            }
            else// If the project hasn't started yet
            {
                lastInvestmentTime[msg.sender] = start;// Save the last investment time for the investor as the time of the project start
            }

            if (invested[msg.sender] == 0) investorsCount++;// Increase the investors counter (for statistics)
            investedTotal += msg.value;// Increase the invested value (for statistics)

            invested[msg.sender] += msg.value;// Increase the invested value for the investor

            administrationFund.transfer(msg.value * 15 / 100);// Transfer the Rocket.cash commission (15% - for advertising (13%) and support (2%))

            emit investment(msg.sender, msg.value, invested[msg.sender], referrer);// Emit the Investment event (for statistics)
        }
        else// If the sent value of ether is 0 - this is an ask to get dividends or money back
        {
            uint withdrawalAmount = availableWithdraw(msg.sender);

            if (withdrawalAmount != 0)// If withdrawal amount is not 0
            {
                emit withdraw(msg.sender, withdrawalAmount, invested[msg.sender]);// Emit the Withdraw event (for statistics)

                msg.sender.transfer(withdrawalAmount);// Transfer the investor's money back minus the Rocket.cash commission or his dividends and bonuses

                lastInvestmentTime[msg.sender] = 0;// Remove investment information about the investor after he has got his money and have been excluded from the Project
                invested[msg.sender]           = 0;// Remove investment information about the investor after he has got his money and have been excluded from the Project
                collected[msg.sender]          = 0;// Remove investment information about the investor after he has got his money and have been excluded from the Project
            }
        }
    }

    function _bytesToAddress (bytes bys) private pure returns (address _address)// This function returns an address of the referrer from the "Data" field
    {
        assembly
        {
            _address := mload(add(bys, 20))
        }
    }

    function availableWithdraw (address investor) public view returns (uint)// This function calculate an available amount for withdrawal
    {
        if (start < now)// If the project has started
        {
            if (invested[investor] != 0)// If the investor of the Rocket.cash hasn't been excluded from the project and ever have been in it
            {
                uint dividends = availableDividends(investor);// Calculate dividends of the investor
                uint canReturn = invested[investor] - invested[investor] * 15 / 100;// The investor can get his money back minus the Rocket.cash commission

                if (canReturn < dividends)// If the investor has dividends more than he has invested minus the Rocket.cash commission
                {
                    return dividends;
                }
                else// If the investor has dividends less than he has invested minus the Rocket.cash commission
                {
                    return canReturn;
                }
            }
            else// If the investor of the Rocket.cash have been excluded from the project or never have been in it - available amount for withdraw = 0
            {
                return 0;
            }
        }
        else// If the project hasn't started yet - available amount for withdraw = 0
        {
            return 0;
        }
    }

    function availableDividends (address investor) private view returns (uint)// This function calculate available for withdraw amount
    {
        return collected[investor] + dailyDividends(investor) * (now - lastInvestmentTime[investor]) / 1 days;// Already collected amount plus Calculated daily dividends (depends on the invested amount) are multiplied by the count of spent days from the last investment
    }

    function dailyDividends (address investor) public view returns (uint)// This function calculate daily dividends (depends on the invested amount)
    {
        if (invested[investor] < 1 ether)// If the invested amount is lower than 1 ether
        {
            return invested[investor] * 222 / 10000;// The interest would be 2.22% (payback in 45 days)
        }
        else if (1 ether <= invested[investor] && invested[investor] < 5 ether)// If the invested amount is higher than 1 ether but lower than 5 ether
        {
            return invested[investor] * 255 / 10000;// The interest would be 2.55% (payback in 40 days)
        }
        else// If the invested amount is higher than 5 ether
        {
            return invested[investor] * 288 / 10000;// The interest would be 2.88% (payback in 35 days)
        }
    }
}