// test/OptimizedBatchTransfer.t.sol
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/OptimizedBatchTransfer.sol";

contract OptimizedBatchTransferTest is Test {
    OptimizedBatchTransfer public token;

    address[] recipients;
    uint256[] amounts;

    function setUp() public {
        token = new OptimizedBatchTransfer();

        // Mint tokens to test account
        token.mint(address(this), 1000000 ether);

        // Setup test data
        for (uint i = 1; i <= 50; i++) {
            recipients.push(address(uint160(i)));
            amounts.push(1 ether);
        }
    }

    function testNormalTransfer() public {
        token.batchTransferNormal(recipients, amounts);

        // Verify transfers
        for (uint i = 0; i < recipients.length; i++) {
            assertEq(token.balances(recipients[i]), amounts[i]);
        }
    }

    function testYulTransfer() public {
        token.batchTransferYul(recipients, amounts);

        // Verify transfers
        for (uint i = 0; i < recipients.length; i++) {
            assertEq(token.balances(recipients[i]), amounts[i]);
        }
    }

    function testGasComparison() public {
        // Normal version
        uint256 gasBeforeNormal = gasleft();
        token.batchTransferNormal(recipients, amounts);
        uint256 gasNormal = gasBeforeNormal - gasleft();

        // Reset state
        setUp();

        // Yul version
        uint256 gasBeforeYul = gasleft();
        token.batchTransferYul(recipients, amounts);
        uint256 gasYul = gasBeforeYul - gasleft();

        // Log results
        console.log("=== GAS COMPARISON (50 recipients) ===");
        console.log("Normal version:", gasNormal);
        console.log("Yul version:", gasYul);
        console.log("Savings:", gasNormal - gasYul);
        console.log(
            "Percentage saved:",
            ((gasNormal - gasYul) * 100) / gasNormal,
            "%"
        );
    }

    function testFailInsufficientBalance() public {
        token.batchTransferYul(recipients, amounts);
        token.batchTransferYul(recipients, amounts); // Should fail
    }
}
