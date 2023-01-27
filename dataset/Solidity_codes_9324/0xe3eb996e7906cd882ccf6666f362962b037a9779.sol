
pragma solidity ^0.5.2;


contract Base {

    event LogString(string str);

    address payable internal operator;
    uint256 constant internal MINIMUM_TIME_TO_REVEAL = 1 days;
    uint256 constant internal TIME_TO_ALLOW_REVOKE = 7 days;
    bool internal isRevokeStarted = false;
    uint256 internal revokeTime = 0; // The time from which we can revoke.
    bool internal active = true;

    mapping (address => mapping (bytes32 => uint256)) private reveal_timestamps;


    constructor ()
        internal
    {
        operator = msg.sender;
    }

    modifier onlyOperator()
    {

        require(msg.sender == operator, "ONLY_OPERATOR");
        _; // The _; defines where the called function is executed.
    }

    function register(bytes32 commitment)
        public
    {

        require(reveal_timestamps[msg.sender][commitment] == 0, "Entry already registered.");
        reveal_timestamps[msg.sender][commitment] = now + MINIMUM_TIME_TO_REVEAL;
    }


    function verifyTimelyRegistration(bytes32 commitment)
        internal view
    {

        uint256 registrationMaturationTime = reveal_timestamps[msg.sender][commitment];
        require(registrationMaturationTime != 0, "Commitment is not registered.");
        require(now >= registrationMaturationTime, "Time for reveal has not passed yet.");
    }


    function calcCommitment(uint256[] memory firstInput, uint256[] memory secondInput)
        public view
        returns (bytes32 commitment)
    {

        address sender = msg.sender;
        uint256 firstLength = firstInput.length;
        uint256 secondLength = secondInput.length;
        uint256[] memory hash_elements = new uint256[](1 + firstLength + secondLength);
        hash_elements[0] = uint256(sender);
        uint256 offset = 1;
        for (uint256 i = 0; i < firstLength; i++) {
            hash_elements[offset + i] = firstInput[i];
        }
        offset = 1 + firstLength;
        for (uint256 i = 0; i < secondLength; i++) {
            hash_elements[offset + i] = secondInput[i];
        }
        commitment = keccak256(abi.encodePacked(hash_elements));
    }

    function claimReward(
        uint256[] memory firstInput,
        uint256[] memory secondInput,
        string memory solutionDescription,
        string memory name)
        public
    {

        require(active == true, "This challenge is no longer active. Thank you for participating.");
        require(firstInput.length > 0, "First input cannot be empty.");
        require(secondInput.length > 0, "Second input cannot be empty.");
        require(firstInput.length == secondInput.length, "Input lengths are not equal.");
        uint256 inputLength = firstInput.length;
        bool sameInput = true;
        for (uint256 i = 0; i < inputLength; i++) {
            if (firstInput[i] != secondInput[i]) {
                sameInput = false;
            }
        }
        require(sameInput == false, "Inputs are equal.");
        bool sameHash = true;
        uint256[] memory firstHash = applyHash(firstInput);
        uint256[] memory secondHash = applyHash(secondInput);
        require(firstHash.length == secondHash.length, "Output lengths are not equal.");
        uint256 outputLength = firstHash.length;
        for (uint256 i = 0; i < outputLength; i++) {
            if (firstHash[i] != secondHash[i]) {
                sameHash = false;
            }
        }
        require(sameHash == true, "Not a collision.");
        verifyTimelyRegistration(calcCommitment(firstInput, secondInput));

        active = false;
        emit LogString(solutionDescription);
        emit LogString(name);
        msg.sender.transfer(address(this).balance);
    }

    function applyHash(uint256[] memory elements)
        public view
        returns (uint256[] memory elementsHash)
    {

        elementsHash = sponge(elements);
    }

    function startRevoke()
        public
        onlyOperator()
    {

        require(isRevokeStarted == false, "Revoke already started.");
        isRevokeStarted = true;
        revokeTime = now + TIME_TO_ALLOW_REVOKE;
    }

    function revokeReward()
        public
        onlyOperator()
    {

        require(isRevokeStarted == true, "Revoke not started yet.");
        require(now >= revokeTime, "Revoke time not passed.");
        active = false;
        operator.transfer(address(this).balance);
    }

    function sponge(uint256[] memory inputs)
        internal view
        returns (uint256[] memory outputElements);


    function getStatus()
        public view
        returns (bool[] memory status)
    {

        status = new bool[](2);
        status[0] = isRevokeStarted;
        status[1] = active;
    }
}

pragma solidity ^0.5.2;


contract Sponge {

    uint256 prime;
    uint256 r;
    uint256 c;
    uint256 m;
    uint256 outputSize;
    uint256 nRounds;

    constructor (uint256 prime_, uint256 r_, uint256 c_, uint256 nRounds_)
        public
    {
        prime = prime_;
        r = r_;
        c = c_;
        m = r + c;
        outputSize = c;
        nRounds = nRounds_;
    }

    function LoadAuxdata()
        internal view
        returns (uint256[] memory /*auxdata*/);


    function permutation_func(uint256[] memory /*auxdata*/, uint256[] memory /*elements*/)
        internal view
        returns (uint256[] memory /*hash_elements*/);


    function sponge(uint256[] memory inputs)
        internal view
        returns (uint256[] memory outputElements)
    {

        uint256 inputLength = inputs.length;
        for (uint256 i = 0; i < inputLength; i++) {
            require(inputs[i] < prime, "elements do not belong to the field");
        }

        require(inputLength % r == 0, "Number of field elements is not divisible by r.");

        uint256[] memory state = new uint256[](m);
        for (uint256 i = 0; i < m; i++) {
            state[i] = 0; // fieldZero.
        }

        uint256[] memory auxData = LoadAuxdata();
        uint256 n_columns = inputLength / r;
        for (uint256 i = 0; i < n_columns; i++) {
            for (uint256 j = 0; j < r; j++) {
                state[j] = addmod(state[j], inputs[i * r + j], prime);
            }
            state = permutation_func(auxData, state);
        }

        require(outputSize <= r, "No support for more than r output elements.");
        outputElements = new uint256[](outputSize);
        for (uint256 i = 0; i < outputSize; i++) {
            outputElements[i] = state[i];
        }
    }

    function getParameters()
        public view
        returns (uint256[] memory status)
    {

        status = new uint256[](4);
        status[0] = prime;
        status[1] = r;
        status[2] = c;
        status[3] = nRounds;
    }
}


pragma solidity ^0.5.2;



contract STARK_Friendly_Hash_Challenge_Poseidon_S45b is Base, Sponge {

    uint256 MAX_CONSTANTS_PER_CONTRACT = 768;

    address[] roundConstantsContracts;
    address mdsContract;
    uint256 nPartialRounds;

    constructor (
        uint256 prime,  uint256 r,  uint256 c, uint256 nFullRounds,
        uint256 nPartialRounds_, address[] memory roundConstantsContracts_, address mdsContract_)
        public payable
        Sponge(prime, r, c, nFullRounds + nPartialRounds_)
    {
        nPartialRounds = nPartialRounds_;
        roundConstantsContracts = roundConstantsContracts_;
        mdsContract = mdsContract_;
    }

    function LoadAuxdata()
    internal view returns (uint256[] memory auxData)
    {

        uint256 round_constants = m*nRounds;
        require (
            round_constants <= 2 * MAX_CONSTANTS_PER_CONTRACT,
            "The code supports up to 2 roundConstantsContracts." );

        uint256 mdsSize = m * m;
        auxData = new uint256[](round_constants + mdsSize);

        uint256 first_contract_n_elements = ((round_constants > MAX_CONSTANTS_PER_CONTRACT) ?
            MAX_CONSTANTS_PER_CONTRACT : round_constants);
        uint256 second_contract_n_elements = round_constants - first_contract_n_elements;

        address FirstRoundsContractAddr = roundConstantsContracts[0];
        address SecondRoundsContractAddr = roundConstantsContracts[1];
        address mdsContractAddr = mdsContract;

        assembly {
            let offset := add(auxData, 0x20)
            let mdsSizeInBytes := mul(mdsSize, 0x20)
            extcodecopy(mdsContractAddr, offset, 0, mdsSizeInBytes)
            offset := add(offset, mdsSizeInBytes)
            let firstSize := mul(first_contract_n_elements, 0x20)
            extcodecopy(FirstRoundsContractAddr, offset, 0, firstSize)
            offset := add(offset, firstSize)
            let secondSize := mul(second_contract_n_elements, 0x20)
            extcodecopy(SecondRoundsContractAddr, offset, 0, secondSize)
        }
    }


    function hades_round(
        uint256[] memory auxData, bool is_full_round, uint256 round_ptr,
        uint256[] memory workingArea, uint256[] memory elements)
        internal view {


        uint256 prime_ = prime;

        uint256 m_ = workingArea.length;

        for (uint256 i = 0; i < m_; i++) {
            workingArea[i] = addmod(elements[i], auxData[round_ptr + i], prime_);
        }

        for (uint256 i = is_full_round ? 0 : m_ - 1; i < m_; i++) {
            workingArea[i] = mulmod(
                mulmod(workingArea[i], workingArea[i], prime_), workingArea[i], prime_);
        }

        assembly {
            let mdsRowPtr := add(auxData, 0x20)
            let stateSize := mul(m_, 0x20)
            let workingAreaPtr := add(workingArea, 0x20)
            let statePtr := add(elements, 0x20)
            let mdsEnd := add(mdsRowPtr, mul(m_, stateSize))

            for {} lt(mdsRowPtr, mdsEnd) { mdsRowPtr := add(mdsRowPtr, stateSize) } {
                let sum := 0
                for { let offset := 0} lt(offset, stateSize) { offset := add(offset, 0x20) } {
                    sum := addmod(
                        sum,
                        mulmod(mload(add(mdsRowPtr, offset)),
                               mload(add(workingAreaPtr, offset)),
                               prime_),
                        prime_)
                }

                mstore(statePtr, sum)
                statePtr := add(statePtr, 0x20)
            }
        }
    }


    function permutation_func(uint256[] memory auxData, uint256[] memory elements)
        internal view
        returns (uint256[] memory hash_elements)
    {
        uint256 m_ = m;
        require (elements.length == m, "elements.length != m.");

        uint256 round_ptr = (m_ * m_);
        uint256[] memory workingArea = new uint256[](m_);

        uint256 half_full_rounds = (nRounds - nPartialRounds) / 2;

        for (uint256 i = 0; i < half_full_rounds; i++) {
            hades_round(auxData, true, round_ptr, workingArea, elements);
            round_ptr += m_;
        }

        for (uint256 i = 0; i < nPartialRounds; i++) {
            hades_round(auxData, false, round_ptr, workingArea, elements);
            round_ptr += m_;
        }

        for (uint256 i = 0; i < half_full_rounds; i++) {
            hades_round(auxData, true, round_ptr, workingArea, elements);
            round_ptr += m_;
        }

        return elements;
    }
}
