

pragma solidity ^0.5.0;



library SafeMath {



    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(
            c / a == b,
            "Overflow when multiplying."
        );

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(
            b > 0,
            "Cannot do attempted division by less than or equal to zero."
        );
        uint256 c = a / b;


        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(
            b <= a,
            "Underflow when subtracting."
        );
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(
            c >= a,
            "Overflow when adding."
        );

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(
            b != 0,
            "Cannot do attempted division by zero (in `mod()`)."
        );

        return a % b;
    }
}


pragma solidity ^0.5.0;


interface OrganizationInterface {


    function isOrganization(
        address _organization
    )
        external
        view
        returns (bool isOrganization_);


    function isWorker(address _worker) external view returns (bool isWorker_);


}


pragma solidity ^0.5.0;





contract Organization is OrganizationInterface {




    using SafeMath for uint256;



    event OwnershipTransferInitiated(
        address indexed proposedOwner,
        address currentOwner
    );

    event OwnershipTransferCompleted(address newOwner, address previousOwner);

    event AdminAddressChanged(address indexed newAdmin, address previousAdmin);

    event WorkerSet(address indexed worker, uint256 expirationHeight);

    event WorkerUnset(address worker);



    address public owner;

    address public proposedOwner;

    address public admin;

    mapping(address => uint256) public workers;



    modifier onlyOwner() {

        require(
            msg.sender == owner,
            "Only owner is allowed to call this method."
        );

        _;
    }

    modifier onlyOwnerOrAdmin() {

        require(
            msg.sender == owner || msg.sender == admin,
            "Only owner and admin are allowed to call this method."
        );

        _;
    }



    constructor(
        address _owner,
        address _admin,
        address[] memory _workers,
        uint256 _expirationHeight
    )
        public
    {
        require(
            _owner != address(0),
            "The owner must not be the zero address."
        );

        owner = _owner;
        admin = _admin;

        for(uint256 i = 0; i < _workers.length; i++) {
            setWorkerInternal(_workers[i], _expirationHeight);
        }
    }



    function initiateOwnershipTransfer(
        address _proposedOwner
    )
        external
        onlyOwner
        returns (bool success_)
    {

        require(
            _proposedOwner != owner,
            "Proposed owner address can't be current owner address."
        );

        proposedOwner = _proposedOwner;

        emit OwnershipTransferInitiated(_proposedOwner, owner);

        success_ = true;
    }

    function completeOwnershipTransfer() external returns (bool success_)
    {

        require(
            msg.sender == proposedOwner,
            "Caller is not proposed owner address."
        );

        emit OwnershipTransferCompleted(proposedOwner, owner);

        owner = proposedOwner;
        proposedOwner = address(0);

        success_ = true;
    }

    function setAdmin(
        address _admin
    )
        external
        onlyOwnerOrAdmin
        returns (bool success_)
    {

        if (admin != _admin) {
            emit AdminAddressChanged(_admin, admin);
            admin = _admin;
        }

        success_ = true;
    }

    function setWorker(
        address _worker,
        uint256 _expirationHeight
    )
        external
        onlyOwnerOrAdmin
    {

        setWorkerInternal(_worker, _expirationHeight);
    }

    function unsetWorker(
        address _worker
    )
        external
        onlyOwnerOrAdmin
        returns (bool isUnset_)
    {

        if (workers[_worker] > 0) {
            delete workers[_worker];
            emit WorkerUnset(_worker);

            isUnset_ = true;
        }
    }

    function isOrganization(
        address _organization
    )
        external
        view
        returns (bool isOrganization_)
    {

        isOrganization_ = _organization == owner || _organization == admin;
    }

    function isWorker(address _worker) external view returns (bool isWorker_)
    {

        isWorker_ = workers[_worker] > block.number;
    }



    function setWorkerInternal(
        address _worker,
        uint256 _expirationHeight
    )
        private
    {

        require(
            _worker != address(0),
            "Worker address cannot be null."
        );

        require(
            _expirationHeight > block.number,
            "Expiration height must be in the future."
        );

        workers[_worker] = _expirationHeight;

        emit WorkerSet(_worker, _expirationHeight);
    }

}