// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {EazyVote} from "../src/EazyVote.sol";

contract EazyVoteDeploy is Script {
    //
    event EazyVoteCreated(address eazyVote);

    function run() external returns (EazyVote) {
        EazyVote eazyVote = new EazyVote();
        emit EazyVoteCreated((address(eazyVote)));
        return eazyVote;
    }
    //
}
