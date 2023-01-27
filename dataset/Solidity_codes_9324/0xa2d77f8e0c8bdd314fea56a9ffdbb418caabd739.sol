

pragma solidity ^0.5.1;

interface IPayRegistry {

    function calculatePayId(bytes32 _payHash, address _setter) external pure returns(bytes32);


    function setPayAmount(bytes32 _payHash, uint _amt) external;


    function setPayDeadline(bytes32 _payHash, uint _deadline) external;


    function setPayInfo(bytes32 _payHash, uint _amt, uint _deadline) external;


    function setPayAmounts(bytes32[] calldata _payHashes, uint[] calldata _amts) external;


    function setPayDeadlines(bytes32[] calldata _payHashes, uint[] calldata _deadlines) external;


    function setPayInfos(bytes32[] calldata _payHashes, uint[] calldata _amts, uint[] calldata _deadlines) external;


    function getPayAmounts(
        bytes32[] calldata _payIds,
        uint _lastPayResolveDeadline
    ) external view returns(uint[] memory);


    function getPayInfo(bytes32 _payId) external view returns(uint, uint);


    event PayInfoUpdate(bytes32 indexed payId, uint amount, uint resolveDeadline);
}


pragma solidity ^0.5.1;


contract PayRegistry is IPayRegistry {

    struct PayInfo {
        uint amount;
        uint resolveDeadline;
    }

    mapping(bytes32 => PayInfo) public payInfoMap;

    function calculatePayId(bytes32 _payHash, address _setter) public pure returns(bytes32) {

        return keccak256(abi.encodePacked(_payHash, _setter));
    }

    function setPayAmount(bytes32 _payHash, uint _amt) external {

        bytes32 payId = calculatePayId(_payHash, msg.sender);
        PayInfo storage payInfo = payInfoMap[payId];
        payInfo.amount = _amt;

        emit PayInfoUpdate(payId, _amt, payInfo.resolveDeadline);
    }

    function setPayDeadline(bytes32 _payHash, uint _deadline) external {

        bytes32 payId = calculatePayId(_payHash, msg.sender);
        PayInfo storage payInfo = payInfoMap[payId];
        payInfo.resolveDeadline = _deadline;

        emit PayInfoUpdate(payId, payInfo.amount, _deadline);
    }

    function setPayInfo(bytes32 _payHash, uint _amt, uint _deadline) external {

        bytes32 payId = calculatePayId(_payHash, msg.sender);
        PayInfo storage payInfo = payInfoMap[payId];
        payInfo.amount = _amt;
        payInfo.resolveDeadline = _deadline;

        emit PayInfoUpdate(payId, _amt, _deadline);
    }

    function setPayAmounts(bytes32[] calldata _payHashes, uint[] calldata _amts) external {

        require(_payHashes.length == _amts.length, "Lengths do not match");

        bytes32 payId;
        address msgSender = msg.sender;
        for (uint i = 0; i < _payHashes.length; i++) {
            payId = calculatePayId(_payHashes[i], msgSender);
            PayInfo storage payInfo = payInfoMap[payId];
            payInfo.amount = _amts[i];

            emit PayInfoUpdate(payId, _amts[i], payInfo.resolveDeadline);
        }
    }

    function setPayDeadlines(bytes32[] calldata _payHashes, uint[] calldata _deadlines) external {

        require(_payHashes.length == _deadlines.length, "Lengths do not match");

        bytes32 payId;
        address msgSender = msg.sender;
        for (uint i = 0; i < _payHashes.length; i++) {
            payId = calculatePayId(_payHashes[i], msgSender);
            PayInfo storage payInfo = payInfoMap[payId];
            payInfo.resolveDeadline = _deadlines[i];

            emit PayInfoUpdate(payId, payInfo.amount, _deadlines[i]);
        }
    }

    function setPayInfos(bytes32[] calldata _payHashes, uint[] calldata _amts, uint[] calldata _deadlines) external {

        require(
            _payHashes.length == _amts.length && _payHashes.length == _deadlines.length,
            "Lengths do not match"
        );

        bytes32 payId;
        address msgSender = msg.sender;
        for (uint i = 0; i < _payHashes.length; i++) {
            payId = calculatePayId(_payHashes[i], msgSender);
            PayInfo storage payInfo = payInfoMap[payId];
            payInfo.amount = _amts[i];
            payInfo.resolveDeadline = _deadlines[i];

            emit PayInfoUpdate(payId, _amts[i], _deadlines[i]);
        }
    }

    function getPayAmounts(
        bytes32[] calldata _payIds,
        uint _lastPayResolveDeadline
    )
        external view returns(uint[] memory)
    {

        uint[] memory amounts = new uint[](_payIds.length);
        for (uint i = 0; i < _payIds.length; i++) {
            if (payInfoMap[_payIds[i]].resolveDeadline == 0) {
                require(block.number > _lastPayResolveDeadline, "Payment is not finalized");
            } else {
                require(
                    block.number > payInfoMap[_payIds[i]].resolveDeadline,
                    "Payment is not finalized"
                );
            }
            amounts[i] = payInfoMap[_payIds[i]].amount;
        }
        return amounts;
    }

    function getPayInfo(bytes32 _payId) external view returns(uint, uint) {

        PayInfo storage payInfo = payInfoMap[_payId];
        return (payInfo.amount, payInfo.resolveDeadline);
    }
}