pragma solidity 0.6.12;

pragma experimental ABIEncoderV2;

library RightsManager {



    enum Permissions { PAUSE_SWAPPING,
                       CHANGE_SWAP_FEE,
                       CHANGE_WEIGHTS,
                       ADD_REMOVE_TOKENS,
                       WHITELIST_LPS,
                       CHANGE_CAP }

    struct Rights {
        bool canPauseSwapping;
        bool canChangeSwapFee;
        bool canChangeWeights;
        bool canAddRemoveTokens;
        bool canWhitelistLPs;
        bool canChangeCap;
    }

    bool public constant DEFAULT_CAN_PAUSE_SWAPPING = false;
    bool public constant DEFAULT_CAN_CHANGE_SWAP_FEE = true;
    bool public constant DEFAULT_CAN_CHANGE_WEIGHTS = true;
    bool public constant DEFAULT_CAN_ADD_REMOVE_TOKENS = false;
    bool public constant DEFAULT_CAN_WHITELIST_LPS = false;
    bool public constant DEFAULT_CAN_CHANGE_CAP = false;


    function constructRights(bool[] calldata a) external pure returns (Rights memory) {

        if (a.length == 0) {
            return Rights(DEFAULT_CAN_PAUSE_SWAPPING,
                          DEFAULT_CAN_CHANGE_SWAP_FEE,
                          DEFAULT_CAN_CHANGE_WEIGHTS,
                          DEFAULT_CAN_ADD_REMOVE_TOKENS,
                          DEFAULT_CAN_WHITELIST_LPS,
                          DEFAULT_CAN_CHANGE_CAP);
        }
        else {
            return Rights(a[0], a[1], a[2], a[3], a[4], a[5]);
        }
    }

    function convertRights(Rights calldata rights) external pure returns (bool[] memory) {

        bool[] memory result = new bool[](6);

        result[0] = rights.canPauseSwapping;
        result[1] = rights.canChangeSwapFee;
        result[2] = rights.canChangeWeights;
        result[3] = rights.canAddRemoveTokens;
        result[4] = rights.canWhitelistLPs;
        result[5] = rights.canChangeCap;

        return result;
    }


    function hasPermission(Rights calldata self, Permissions permission) external pure returns (bool) {

        if (Permissions.PAUSE_SWAPPING == permission) {
            return self.canPauseSwapping;
        }
        else if (Permissions.CHANGE_SWAP_FEE == permission) {
            return self.canChangeSwapFee;
        }
        else if (Permissions.CHANGE_WEIGHTS == permission) {
            return self.canChangeWeights;
        }
        else if (Permissions.ADD_REMOVE_TOKENS == permission) {
            return self.canAddRemoveTokens;
        }
        else if (Permissions.WHITELIST_LPS == permission) {
            return self.canWhitelistLPs;
        }
        else if (Permissions.CHANGE_CAP == permission) {
            return self.canChangeCap;
        }
    }

}