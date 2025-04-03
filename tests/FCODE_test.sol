// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4.0;

import "../contracts/FCODE.sol";

contract FCODETest {
    FCODE private fcode;
    address private owner;
    address private user1;
    address private user2;
    uint256 private initialSupply = 1000000; // 1 million tokens
    
    // Các biến để lưu kết quả test
    bool public lastTestResult;
    string public lastTestName;
    string public lastErrorMessage;
    
    constructor() {
        owner = address(this);
        user1 = address(0x1111111111111111111111111111111111111111);
        user2 = address(0x2222222222222222222222222222222222222222);
    }
    
    function setUp() public {
        // Khởi tạo hợp đồng mới cho mỗi testcase
        fcode = new FCODE(initialSupply);
    }
    
    function recordSuccess(string memory testName) internal {
        lastTestResult = true;
        lastTestName = testName;
        lastErrorMessage = "";
    }
    
    function recordFailure(string memory testName, string memory errorMessage) internal {
        lastTestResult = false;
        lastTestName = testName;
        lastErrorMessage = errorMessage;
    }
    
    function assertEqual(uint256 a, uint256 b, string memory message) internal returns (bool) {
        if (a != b) {
            recordFailure(lastTestName, message);
            return false;
        }
        return true;
    }
    
    function assertEqual(address a, address b, string memory message) internal returns (bool) {
        if (a != b) {
            recordFailure(lastTestName, message);
            return false;
        }
        return true;
    }
    
    function assertEqual(string memory a, string memory b, string memory message) internal returns (bool) {
        if (keccak256(bytes(a)) != keccak256(bytes(b))) {
            recordFailure(lastTestName, message);
            return false;
        }
        return true;
    }
    
    // Test khởi tạo token
    function testInitialSupply() public {
        setUp();
        string memory testName = "testInitialSupply";
        lastTestName = testName;
        
        uint256 totalSupply = fcode.totalSupply();
        uint256 expectedSupply = initialSupply * 10**18; // 18 decimals
        uint256 ownerBalance = fcode.balanceOf(owner);
        
        if (!assertEqual(totalSupply, expectedSupply, "Total supply should match expected value")) return;
        if (!assertEqual(ownerBalance, expectedSupply, "Owner should have full initial supply")) return;
        
        recordSuccess(testName);
    }
    
    // Test metadata của token
    function testTokenMetadata() public {
        setUp();
        string memory testName = "testTokenMetadata";
        lastTestName = testName;
        
        string memory name = fcode.name();
        string memory symbol = fcode.symbol();
        uint8 decimals = fcode.decimals();
        
        if (!assertEqual(name, "FCODE", "Token name should be FCODE")) return;
        if (!assertEqual(symbol, "FCODE", "Token symbol should be FCODE")) return;
        if (!assertEqual(uint256(decimals), uint256(18), "Token should have 18 decimals")) return;
        
        recordSuccess(testName);
    }
    
    // Test chuyển token
    function testTransfer() public {
        setUp();
        string memory testName = "testTransfer";
        lastTestName = testName;
        
        uint256 transferAmount = 1000 * 10**18;
        
        uint256 initialOwnerBalance = fcode.balanceOf(owner);
        uint256 initialUser1Balance = fcode.balanceOf(user1);
        
        fcode.transfer(user1, transferAmount);
        
        uint256 finalOwnerBalance = fcode.balanceOf(owner);
        uint256 finalUser1Balance = fcode.balanceOf(user1);
        
        if (!assertEqual(finalOwnerBalance, initialOwnerBalance - transferAmount, "Owner balance should decrease")) return;
        if (!assertEqual(finalUser1Balance, initialUser1Balance + transferAmount, "User1 balance should increase")) return;
        
        recordSuccess(testName);
    }
    
    // Test mint token
    function testMint() public {
        setUp();
        string memory testName = "testMint";
        lastTestName = testName;
        
        uint256 mintAmount = 5000 * 10**18;
        uint256 initialTotalSupply = fcode.totalSupply();
        uint256 initialUser1Balance = fcode.balanceOf(user1);
        
        fcode.mint(user1, mintAmount);
        
        uint256 finalTotalSupply = fcode.totalSupply();
        uint256 finalUser1Balance = fcode.balanceOf(user1);
        
        if (!assertEqual(finalTotalSupply, initialTotalSupply + mintAmount, "Total supply should increase")) return;
        if (!assertEqual(finalUser1Balance, initialUser1Balance + mintAmount, "User1 balance should increase")) return;
        
        recordSuccess(testName);
    }
    
    // Test burn token
    function testBurn() public {
        setUp();
        string memory testName = "testBurn";
        lastTestName = testName;
        
        // First give tokens to this contract
        uint256 burnAmount = 1000 * 10**18;
        
        uint256 initialTotalSupply = fcode.totalSupply();
        
        // Burn tokens
        fcode.burn(burnAmount);
        
        uint256 finalTotalSupply = fcode.totalSupply();
        
        if (!assertEqual(finalTotalSupply, initialTotalSupply - burnAmount, "Total supply should decrease")) return;
        
        recordSuccess(testName);
    }
    
    // Test withdraw
    function testWithdraw() public payable {
        setUp();
        string memory testName = "testWithdraw";
        lastTestName = testName;
        
        // Fund the contract and set balance
        uint256 ethAmount = 1 ether;
        (bool success, ) = address(fcode).call{value: ethAmount}("");
        require(success, "Failed to send Ether to contract");
        
        // Need to manually set the balance variable, assuming we've added a setter
        (bool setBalanceSuccess, ) = address(fcode).call(abi.encodeWithSignature("setBalance(uint256)", ethAmount));
        require(setBalanceSuccess, "Failed to set balance");
        
        uint256 initialContractBalance = address(fcode).balance;
        uint256 initialOwnerBalance = address(this).balance;
        
        // Withdraw ETH
        fcode.withdraw(ethAmount, payable(address(this)));
        
        uint256 finalContractBalance = address(fcode).balance;
        uint256 finalOwnerBalance = address(this).balance;
        
        if (!assertEqual(finalContractBalance, initialContractBalance - ethAmount, "Contract balance should decrease")) return;
        if (!assertEqual(finalOwnerBalance, initialOwnerBalance + ethAmount, "Owner balance should increase")) return;
        
        recordSuccess(testName);
    }
    
    // Run all tests
    function runAllTests() public {
        testInitialSupply();
        testTokenMetadata();
        testTransfer();
        testMint();
        testBurn();
        // testWithdraw requires funds, so it should be called separately with value
    }
    
    // Để contract có thể nhận Ether
    receive() external payable {}
}