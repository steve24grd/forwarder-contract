// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing OpenZeppelin's ReentrancyGuard for security against reentrancy attacks
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Forwarder is ReentrancyGuard {
    // Address to which funds will be forwarded
    address payable public poolAddress;

    // Event emitted when funds are successfully forwarded
    event FundsForwarded(address indexed sender, uint256 amount, address indexed poolAddress);

    // Event emitted when forwarding fails
    event ForwardingFailed(address indexed sender, uint256 amount, address indexed poolAddress);

    // Event emitted when pool address is updated
    event PoolAddressUpdated(address indexed oldPool, address indexed newPool);

    // Modifier to restrict access to only the contract owner
    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(address payable _poolAddress) {
        require(_poolAddress != address(0), "Invalid pool address");
        poolAddress = _poolAddress;
        owner = msg.sender;
    }

    // Function to update the pool address, restricted to the owner
    function updatePoolAddress(address payable _newPoolAddress) external onlyOwner {
        require(_newPoolAddress != address(0), "Invalid new pool address");
        emit PoolAddressUpdated(poolAddress, _newPoolAddress);
        poolAddress = _newPoolAddress;
    }

    // Fallback function to prevent accidental ETH transfers without data
    fallback() external payable {
        forwardFunds();
    }

    // Receive function to handle plain ETH transfers
    receive() external payable {
        forwardFunds();
    }

    // Explicit forward function to send ETH to the pool address
    function forwardFunds() internal nonReentrant {
        uint256 amount = msg.value;
        require(amount > 0, "No ETH to forward");

        // Forward the ETH to the pool address using call
        (bool success, ) = poolAddress.call{value: amount}("");

        if (success) {
            emit FundsForwarded(msg.sender, amount, poolAddress);
        } else {
            emit ForwardingFailed(msg.sender, amount, poolAddress);
            // Optionally, handle failed forwarding (e.g., revert, store funds, etc.)
            // For this example, we'll revert to ensure funds aren't stuck
            revert("Forwarding failed");
        }
    }
}
