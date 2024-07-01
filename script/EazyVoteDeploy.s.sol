// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {EazyVote} from "../src/EazyVote.sol";

contract EazyVoteDeploy is Script {
    //
    event EazyVoteCreated(address eazyVote);

    function run() external returns (EazyVote) {
        vm.startBroadcast();
        EazyVote eazyVote = new EazyVote();
        vm.stopBroadcast();
        emit EazyVoteCreated((address(eazyVote)));
        return eazyVote;
    }
    //
}
