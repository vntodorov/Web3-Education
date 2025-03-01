// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";
import {BaseContract} from "src/BaseContract.sol";

contract DeployBaseContract is Script {
    function run() external returns (BaseContract) {
        vm.startBroadcast();
        BaseContract baseContract = new BaseContract();
        vm.stopBroadcast();
        return baseContract;
    }
}
