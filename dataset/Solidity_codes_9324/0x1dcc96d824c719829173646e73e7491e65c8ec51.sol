
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
}/// @author Hapi Finance Team

pragma solidity ^0.8.3;


contract Will is Ownable {

    struct Beneficiary {
        address beneficiaryAddress;
        uint256 split; /// multiplied by 10000 (4 decimal point accuracy) - so 0.25 split is 2500
    }

    mapping(address => Beneficiary[]) beneficiaries;

    mapping(address => uint256) cadences;
    mapping(address => uint256) lastCheckIn;

    event TransferSuccess(
        address indexed estateHolder,
        address indexed beneficiary,
        address token,
        uint256 amount
    );

    event TransferFailure(
        address indexed estateHolder,
        address indexed beneficiary,
        address token,
        uint256 amount,
        string message
    );

    event Initialized(address indexed estateHolder);


    function initializeEstate(address beneficiary, uint256 cadence) public {

        require(
            beneficiaries[msg.sender].length == 0,
            "This sender already has an estate initialized"
        );
        require(
            cadence >= 60,
            "Cadence must be greater than 1 minute (60 seconds)"
        );

        if (beneficiary != address(0)) {
            beneficiaries[msg.sender].push(Beneficiary(beneficiary, 10000));
        }
        lastCheckIn[msg.sender] = block.timestamp;
        cadences[msg.sender] = cadence;

        emit Initialized(msg.sender);
    }

    function revoke() public onlyEstateHolder {

        delete beneficiaries[msg.sender];
        lastCheckIn[msg.sender] = 0;
        cadences[msg.sender] = 0;
    }

    function updateBeneficiaries(
        address[] calldata newAddresses,
        uint256[] calldata newSplits
    ) public onlyEstateHolder {

        require(
            newAddresses.length == newSplits.length,
            "There must be the same number of beneficiaries and splits"
        );
        require(
            newAddresses.length > 0,
            "You can't empty all beneficiaries. If you want to terminate the contract, call 'revoke()'"
        );

        uint256 newSplitTotal = 0;

        for (uint256 i = 0; i < newAddresses.length; i++) {
            newSplitTotal += newSplits[i];
            if (newSplitTotal > 10000) break;
        }

        require(
            newSplitTotal <= 10000,
            "The splits for the given beneficiaries exceed 100%. Please re-try."
        );

        delete beneficiaries[msg.sender];

        for (uint256 i = 0; i < newAddresses.length; i++) {
            beneficiaries[msg.sender].push(
                Beneficiary(newAddresses[i], newSplits[i])
            );
        }

        lastCheckIn[msg.sender] = block.timestamp;
    }

    function updateCadence(uint256 cadence) public onlyEstateHolder {

        require(
            cadence >= 60,
            "Cadence must be greater than 1 minute (60 seconds)"
        );
        cadences[msg.sender] = cadence;
        lastCheckIn[msg.sender] = block.timestamp;
    }

    function checkin() public onlyEstateHolder {

        lastCheckIn[msg.sender] = block.timestamp;
    }


    function getTimeSinceLastCheckin()
        public
        view
        onlyEstateHolder
        returns (uint256)
    {

        uint256 lastCheckInMem = lastCheckIn[msg.sender];
        if (lastCheckInMem == 0) {
            return 0;
        }
        return (block.timestamp - lastCheckInMem);
    }

    function isEstateHolder() public view returns (bool) {

        return beneficiaries[msg.sender].length != 0;
    }

    function getBeneficiaries()
        public
        view
        onlyEstateHolder
        returns (Beneficiary[] memory)
    {

        return beneficiaries[msg.sender];
    }


    function getBeneficiariesOwner(address estateHolder)
        public
        view
        onlyOwner
        returns (Beneficiary[] memory)
    {

        return beneficiaries[estateHolder];
    }

    function getCadenceOwner(address estateHolder)
        public
        view
        onlyOwner
        returns (uint256)
    {

        return cadences[estateHolder];
    }

    function getTimeSinceLastCheckinOwner(address estateHolder)
        public
        view
        onlyOwner
        returns (uint256)
    {

        return lastCheckIn[estateHolder];
    }


    function transferIfDead(address estateHolder, address[] calldata tokens)
        public
    {

        require(
            cadences[estateHolder] != 0,
            "No estate exists for the specified address. Please start by having them call 'initializeEstate()'"
        );
        uint256 diff = block.timestamp - lastCheckIn[estateHolder];
        require(diff > cadences[estateHolder], "estate holder isn't dead!");

        for (uint256 i = 0; i < tokens.length; i++) {
            splitTokenForBeneficiaries(tokens[i], estateHolder);
        }
    }


    function splitTokenForBeneficiaries(
        address tokenAddress,
        address estateHolder
    ) private {

        if (!isContract(tokenAddress)) return;
        IERC20 token = IERC20(tokenAddress);
        try token.allowance(estateHolder, address(this)) returns (
            uint256 allowance
        ) {
            try token.balanceOf(estateHolder) returns (uint256 balance) {
                if (allowance == 0 || balance == 0) return;

                if (balance < allowance) {
                    allowance = balance;
                }

                for (
                    uint256 i = 0;
                    i < beneficiaries[estateHolder].length;
                    i++
                ) {
                    uint256 splitTransferAmount = (beneficiaries[estateHolder][
                        i
                    ].split * allowance) / (10000);

                    try
                        token.transferFrom(
                            estateHolder,
                            beneficiaries[estateHolder][i].beneficiaryAddress,
                            splitTransferAmount
                        )
                    {
                        emit TransferSuccess(
                            estateHolder,
                            beneficiaries[estateHolder][i].beneficiaryAddress,
                            tokenAddress,
                            splitTransferAmount
                        );
                    } catch Error(string memory _err) {
                        emit TransferFailure(
                            estateHolder,
                            beneficiaries[estateHolder][i].beneficiaryAddress,
                            tokenAddress,
                            splitTransferAmount,
                            _err
                        );
                        return;
                    }
                }
            } catch {
                return;
            }
        } catch {
            return;
        }
    }

    function isContract(address _addr) private view returns (bool) {

        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }


    modifier onlyEstateHolder() {

        require(
            cadences[msg.sender] != 0,
            "No estate exists for this sender, please start by calling 'initializeEstate()'"
        );
        _;
    }
}