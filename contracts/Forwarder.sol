// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Forwarder {
    address payable public poolAddress;

    constructor(address payable _poolAddress) {
        require(_poolAddress != address(0), "Invalid pool address");
        poolAddress = _poolAddress;
    }

    // Fallback function to accept ETH and forward it
    receive() external payable {
        forwardFunds();
    }

    // Named 'transfer' to mimic the built-in transfer method
    function transfer() external payable {
        forwardFunds();
    }

    function forwardFunds() internal {
        (bool success, ) = poolAddress.call{value: msg.value}("");
        require(success, "Transfer failed.");
    }
}
