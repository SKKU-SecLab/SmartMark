pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

library HodlLib {

    struct PackedHodlItem {
        uint256 packedData;
        address creator;
        address dubiBeneficiary;
        uint96 pendingLockedPrps;
    }

    struct UnpackedHodlItem {
        uint24 id;
        uint16 duration;
        UnpackedFlags flags;
        uint32 lastWithdrawal;
        uint96 lockedPrps;
        uint96 burnedLockedPrps;
    }

    struct UnpackedFlags {
        bool hasDifferentCreator;
        bool hasDifferentDubiBeneficiary;
        bool hasDependentHodlOp;
        bool hasPendingLockedPrps;
    }

    struct PrettyHodlItem {
        uint24 id;
        uint16 duration;
        UnpackedFlags flags;
        uint32 lastWithdrawal;
        uint96 lockedPrps;
        uint96 burnedLockedPrps;
        address creator;
        address dubiBeneficiary;
        uint96 pendingLockedPrps;
    }

    function packHodlItem(UnpackedHodlItem memory _unpackedHodlItem)
        internal
        pure
        returns (uint256)
    {


        uint256 packedData;
        uint256 offset;

        uint24 id = _unpackedHodlItem.id;
        uint24 idMask = (1 << 20) - 1;
        packedData |= uint256(id & idMask) << offset;
        offset += 20;


        uint16 duration = _unpackedHodlItem.duration;
        uint16 durationMask = (1 << 9) - 1;
        packedData |= uint256(duration & durationMask) << offset;
        offset += 9;

        uint32 lastWithdrawal = _unpackedHodlItem.lastWithdrawal;
        uint32 lastWithdrawalMask = (1 << 31) - 1;
        packedData |= uint256(lastWithdrawal & lastWithdrawalMask) << offset;
        offset += 31;

        UnpackedFlags memory flags = _unpackedHodlItem.flags;
        if (flags.hasDifferentCreator) {
            packedData |= 1 << (offset + 0);
        }

        if (flags.hasDifferentDubiBeneficiary) {
            packedData |= 1 << (offset + 1);
        }

        if (flags.hasDependentHodlOp) {
            packedData |= 1 << (offset + 2);
        }

        if (flags.hasPendingLockedPrps) {
            packedData |= 1 << (offset + 3);
        }

        offset += 4;

        packedData |= uint256(_unpackedHodlItem.lockedPrps) << offset;
        offset += 96;

        packedData |= uint256(_unpackedHodlItem.burnedLockedPrps) << offset;
        offset += 96;

        assert(offset == 256);

        return packedData;
    }

    function unpackHodlItem(uint256 packedData)
        internal
        pure
        returns (UnpackedHodlItem memory)
    {

        UnpackedHodlItem memory _unpacked;
        uint256 offset;

        uint24 id = uint24(packedData >> offset);
        uint24 idMask = (1 << 20) - 1;
        _unpacked.id = id & idMask;
        offset += 20;

        uint16 duration = uint16(packedData >> offset);
        uint16 durationMask = (1 << 9) - 1;
        _unpacked.duration = duration & durationMask;
        offset += 9;

        uint32 lastWithdrawal = uint32(packedData >> offset);
        uint32 lastWithdrawalMask = (1 << 31) - 1;
        _unpacked.lastWithdrawal = lastWithdrawal & lastWithdrawalMask;
        offset += 31;

        UnpackedFlags memory flags = _unpacked.flags;

        flags.hasDifferentCreator = (packedData >> (offset + 0)) & 1 == 1;
        flags.hasDifferentDubiBeneficiary =
            (packedData >> (offset + 1)) & 1 == 1;
        flags.hasDependentHodlOp = (packedData >> (offset + 2)) & 1 == 1;
        flags.hasPendingLockedPrps = (packedData >> (offset + 3)) & 1 == 1;

        offset += 4;

        _unpacked.lockedPrps = uint96(packedData >> offset);
        offset += 96;

        _unpacked.burnedLockedPrps = uint96(packedData >> offset);
        offset += 96;

        assert(offset == 256);

        return _unpacked;
    }


    struct PendingHodl {
        address creator;
        uint96 amountPrps;
        address dubiBeneficiary;
        uint96 dubiToMint;
        address prpsBeneficiary;
        uint24 hodlId;
        uint16 duration;
    }

    struct PendingRelease {
        uint24 hodlId;
        uint96 releasablePrps;
        address creator;
    }

    struct PendingWithdrawal {
        address prpsBeneficiary;
        uint96 dubiToMint;
        address creator;
        uint24 hodlId;
    }

    function setLockedPrpsToPending(
        HodlLib.PackedHodlItem[] storage hodlsSender,
        uint96 amount
    ) public {

        uint96 totalLockedPrpsMarkedPending;
        uint256 length = hodlsSender.length;
        for (uint256 i = 0; i < length; i++) {
            HodlLib.PackedHodlItem storage packed = hodlsSender[i];
            HodlLib.UnpackedHodlItem memory unpacked = HodlLib.unpackHodlItem(
                packed.packedData
            );

            if (unpacked.flags.hasDependentHodlOp) {
                continue;
            }

            uint96 remainingPendingPrps = amount - totalLockedPrpsMarkedPending;

            assert(remainingPendingPrps <= amount);

            if (remainingPendingPrps == 0) {
                break;
            }

            uint96 pendingLockedPrps;
            if (unpacked.flags.hasPendingLockedPrps) {
                pendingLockedPrps = packed.pendingLockedPrps;
            }

            uint96 remainingLockedPrps = unpacked.lockedPrps -
                unpacked.burnedLockedPrps -
                pendingLockedPrps;

            assert(remainingLockedPrps <= unpacked.lockedPrps);

            if (remainingLockedPrps == 0) {
                continue;
            }

            if (remainingPendingPrps > remainingLockedPrps) {
                remainingPendingPrps = remainingLockedPrps;
            }

            uint96 updatedPendingPrpsOnHodl = pendingLockedPrps +
                remainingPendingPrps;

            assert(
                updatedPendingPrpsOnHodl <=
                    unpacked.lockedPrps - unpacked.burnedLockedPrps
            );

            totalLockedPrpsMarkedPending += remainingPendingPrps;

            unpacked.flags.hasPendingLockedPrps = true;
            packed.pendingLockedPrps = updatedPendingPrpsOnHodl;
            packed.packedData = HodlLib.packHodlItem(unpacked);
        }

        require(totalLockedPrpsMarkedPending == amount, "H-14");
    }

    function revertLockedPrpsSetToPending(
        HodlLib.PackedHodlItem[] storage hodlsSender,
        uint96 amount
    ) public {

        require(amount > 0, "H-22");

        uint96 remainingPendingLockedPrps = amount;
        uint256 length = hodlsSender.length;

        for (uint256 i = 0; i < length; i++) {
            HodlLib.PackedHodlItem storage packed = hodlsSender[i];
            HodlLib.UnpackedHodlItem memory unpacked = HodlLib.unpackHodlItem(
                packed.packedData
            );

            if (
                !unpacked.flags.hasPendingLockedPrps ||
                unpacked.flags.hasDependentHodlOp
            ) {
                continue;
            }


            uint96 remainingPendingPrpsOnHodl = packed.pendingLockedPrps;
            if (remainingPendingPrpsOnHodl > remainingPendingLockedPrps) {
                remainingPendingPrpsOnHodl = remainingPendingLockedPrps;
            }

            remainingPendingLockedPrps -= remainingPendingPrpsOnHodl;
            packed.pendingLockedPrps -= remainingPendingPrpsOnHodl;

            if (remainingPendingPrpsOnHodl == 0) {
                unpacked.flags.hasPendingLockedPrps = false;
                packed.packedData = HodlLib.packHodlItem(unpacked);
            }

            if (remainingPendingLockedPrps == 0) {
                break;
            }
        }

        assert(remainingPendingLockedPrps == 0);
    }
}