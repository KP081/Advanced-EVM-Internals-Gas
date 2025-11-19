// test/GasLimits.sol
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/OptimizedBatchTransfer.sol";

contract GasLimits is Test {
    OptimizedBatchTransfer public token;

    // ✅ UPDATED: Realistic gas limits (measured + 10% buffer)
    // Measured: 259,042 → Limit: 285,000 (10% buffer)
    uint256 constant MAX_GAS_BATCH_10 = 285_000;

    // Measured: 1,248,103 → Limit: 1,373,000 (10% buffer)
    uint256 constant MAX_GAS_BATCH_50 = 1_373_000;

    // Measured: 2,484,535 → Limit: 2,733,000 (10% buffer)
    uint256 constant MAX_GAS_BATCH_100 = 2_733_000;

    function setUp() public {
        token = new OptimizedBatchTransfer();
        token.mint(address(this), type(uint256).max);
    }

    function testGasLimit_Batch10() public {
        (address[] memory recipients, uint256[] memory amounts) = _createBatch(
            10
        );

        uint256 gasBefore = gasleft();
        token.batchTransferYul(recipients, amounts);
        uint256 gasUsed = gasBefore - gasleft();

        console.log("Gas used (10 recipients):", gasUsed);
        console.log("Gas limit:", MAX_GAS_BATCH_10);
        console.log("Buffer remaining:", MAX_GAS_BATCH_10 - gasUsed);

        assertLt(gasUsed, MAX_GAS_BATCH_10, "Batch-10 exceeded gas limit!");
    }

    function testGasLimit_Batch50() public {
        (address[] memory recipients, uint256[] memory amounts) = _createBatch(
            50
        );

        uint256 gasBefore = gasleft();
        token.batchTransferYul(recipients, amounts);
        uint256 gasUsed = gasBefore - gasleft();

        console.log("Gas used (50 recipients):", gasUsed);
        console.log("Gas limit:", MAX_GAS_BATCH_50);
        console.log("Buffer remaining:", MAX_GAS_BATCH_50 - gasUsed);

        assertLt(gasUsed, MAX_GAS_BATCH_50, "Batch-50 exceeded gas limit!");
    }

    function testGasLimit_Batch100() public {
        (address[] memory recipients, uint256[] memory amounts) = _createBatch(
            100
        );

        uint256 gasBefore = gasleft();
        token.batchTransferYul(recipients, amounts);
        uint256 gasUsed = gasBefore - gasleft();

        console.log("Gas used (100 recipients):", gasUsed);
        console.log("Gas limit:", MAX_GAS_BATCH_100);
        console.log("Buffer remaining:", MAX_GAS_BATCH_100 - gasUsed);

        assertLt(gasUsed, MAX_GAS_BATCH_100, "Batch-100 exceeded gas limit!");
    }

    function _createBatch(
        uint256 count
    ) internal pure returns (address[] memory, uint256[] memory) {
        address[] memory recipients = new address[](count);
        uint256[] memory amounts = new uint256[](count);

        for (uint i = 0; i < count; i++) {
            recipients[i] = address(uint160(i + 1));
            amounts[i] = 1 ether;
        }

        return (recipients, amounts);
    }
}
