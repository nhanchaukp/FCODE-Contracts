// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FCODE is ERC20, Ownable {
    uint256 public balance;

    constructor(uint256 initialSupply) ERC20("FCODE", "FCODE") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }
    
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
    
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function withdraw(uint amount, address payable destAddress) public {
        require(msg.sender==owner(), "Only owner can withdraw.");
        require(amount <= balance, "Insufficient funds.");
        destAddress.transfer(amount);
        balance-=amount;
    }
}