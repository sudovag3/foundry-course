// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

contract Helper is Script {
    function _getDeployerKey() internal view returns (uint256) {
        if (block.chainid == 11155111) {
            return vm.envUint("PRIVATE_KEY");
        } else {
            return 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        }
    }
}
