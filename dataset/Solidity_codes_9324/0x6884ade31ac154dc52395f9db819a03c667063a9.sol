pragma solidity ^0.8.0;


interface IERC20 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    event NameChanged(string name, string symbol);

    function decimals() external view returns (uint8);


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

abstract contract IRecoverable {

    function claimPeriod() external view virtual returns (uint256);
    
    function notifyClaimMade(address target) external virtual;

    function notifyClaimDeleted(address target) external virtual;

    function getCollateralRate(address collateral) public view virtual returns(uint256);

    function recover(address oldAddress, address newAddress) external virtual;

}// MIT
pragma solidity ^0.8.0;

abstract contract IRecoveryHub {

    function setRecoverable(bool flag) external virtual;
    
    function deleteClaim(address target) external virtual;

    function clearClaimFromToken(address holder) external virtual;

}/**
* LicenseRef-Aktionariat
*
* MIT License with Automated License Fee Payments
*
* Copyright (c) 2020 Aktionariat AG (aktionariat.com)
*
* Permission is hereby granted to any person obtaining a copy of this software
* and associated documentation files (the "Software"), to deal in the Software
* without restriction, including without limitation the rights to use, copy,
* modify, merge, publish, distribute, sublicense, and/or sell copies of the
* Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* - The above copyright notice and this permission notice shall be included in
*   all copies or substantial portions of the Software.
* - All automated license fee payments integrated into this and related Software
*   are preserved.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
pragma solidity ^0.8.0;



contract RecoveryHub is IRecoveryHub {


    struct Claim {
        address claimant; // the person who created the claim
        uint256 collateral; // the amount of collateral deposited
        uint256 timestamp;  // the timestamp of the block in which the claim was made
        address currencyUsed; // The currency (XCHF) can be updated, we record the currency used for every request
    }

    mapping(address => mapping (address => Claim)) public claims; // there can be at most one claim per token and claimed address
    mapping(address => bool) public recoveryDisabled; // disable claimability (e.g. for long term storage)

    event ClaimMade(address indexed token, address indexed lostAddress, address indexed claimant, uint256 balance);
    event ClaimCleared(address indexed token, address indexed lostAddress, uint256 collateral);
    event ClaimDeleted(address indexed token, address indexed lostAddress, address indexed claimant, uint256 collateral);
    event ClaimResolved(address indexed token, address indexed lostAddress, address indexed claimant, uint256 collateral);

    function setRecoverable(bool enabled) external override {

        recoveryDisabled[msg.sender] = !enabled;
    }

    function isRecoveryEnabled(address target) public view returns (bool) {

        return !recoveryDisabled[target];
    }

    function declareLost(address token, address collateralType, address lostAddress) external {

        require(isRecoveryEnabled(lostAddress), "disabled");
        uint256 collateralRate = IRecoverable(token).getCollateralRate(collateralType);
        require(collateralRate > 0, "bad collateral");
        address claimant = msg.sender;
        uint256 balance = IERC20(token).balanceOf(lostAddress);
        uint256 collateral = balance * collateralRate;
        IERC20 currency = IERC20(collateralType);
        require(balance > 0, "empty");
        require(claims[token][lostAddress].collateral == 0, "already claimed");
        require(currency.transferFrom(claimant, address(this), collateral));

        claims[token][lostAddress] = Claim({
            claimant: claimant,
            collateral: collateral,
            timestamp: block.timestamp,
            currencyUsed: collateralType
        });

        IRecoverable(token).notifyClaimMade(lostAddress);
        emit ClaimMade(token, lostAddress, claimant, balance);
    }

    function getClaimant(address token, address lostAddress) external view returns (address) {

        return claims[token][lostAddress].claimant;
    }

    function getCollateral(address token, address lostAddress) external view returns (uint256) {

        return claims[token][lostAddress].collateral;
    }

    function getCollateralType(address token, address lostAddress) external view returns (address) {

        return claims[token][lostAddress].currencyUsed;
    }

    function getTimeStamp(address token, address lostAddress) external view returns (uint256) {

        return claims[token][lostAddress].timestamp;
    }

    function clearClaimFromToken(address holder) external override {

        clearClaim(msg.sender, holder);
    }

    function clearClaimFromUser(address token) external {

        clearClaim(token, msg.sender);
    }

    function clearClaim(address token, address holder) private {

        Claim memory claim = claims[token][holder];
        if (claim.collateral != 0) {
            IERC20 currency = IERC20(claim.currencyUsed);
            delete claims[token][holder];
            require(currency.transfer(address(this), claim.collateral), "could not return collateral");
            emit ClaimCleared(token, holder, claim.collateral);
            IRecoverable(token).notifyClaimDeleted(holder);
        }
    }

    function recover(address token, address lostAddress) external {

        Claim memory claim = claims[token][lostAddress];
        address claimant = claim.claimant;
        require(claimant == msg.sender, "not claimant");
        uint256 collateral = claim.collateral;
        IERC20 currency = IERC20(claim.currencyUsed);
        require(collateral != 0, "not found");
        require(claim.timestamp + IRecoverable(token).claimPeriod() <= block.timestamp, "too early");
        delete claims[token][lostAddress];
        IRecoverable(token).notifyClaimDeleted(lostAddress);
        require(currency.transfer(claimant, collateral));
        IRecoverable(token).recover(lostAddress, claimant);
        emit ClaimResolved(token, lostAddress, claimant, collateral);
    }

    function deleteClaim(address lostAddress) external override {

        address token = msg.sender;
        Claim memory claim = claims[token][lostAddress];
        IERC20 currency = IERC20(claim.currencyUsed);
        require(claim.collateral != 0, "not found");
        delete claims[token][lostAddress];
        IRecoverable(token).notifyClaimDeleted(lostAddress);
        require(currency.transfer(claim.claimant, claim.collateral));
        emit ClaimDeleted(token, lostAddress, claim.claimant, claim.collateral);
    }

}