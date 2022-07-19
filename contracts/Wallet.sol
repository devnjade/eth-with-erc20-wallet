// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Openzeppelin contracts
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Wallet {
    address payable public owner;
    uint256 public balance;

    mapping(IERC20 => uint256) public tokenBalances;

    constructor() {
        owner = payable(msg.sender);
    }

    event OtherReceipt(address sender, address recipient, uint256 value);

    event Receipt(address sender, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    receive() external payable {
        balance += msg.value;
        emit Receipt(msg.sender, msg.value);
    }

    function depositEth() external payable {
        balance += msg.value;
        emit Receipt(msg.sender, msg.value);
    }

    function transferEth(address payable to, uint256 amount) public onlyOwner {
        require(amount <= balance, "Insufficient funds");

        to.transfer(amount);
        balance -= amount;
        emit OtherReceipt(msg.sender, to, amount);
    }

    function withdrawEth(uint256 amount) public onlyOwner {
        require(amount <= balance, "Insufficient funds");

        owner.transfer(amount);
        balance -= amount;
        emit Receipt(msg.sender, amount);
    }

    function depositToken(IERC20 token, uint256 amount) public {
        require(amount <= token.balanceOf(msg.sender), "Insufficient funds");

        token.transfer(msg.sender, amount);
        tokenBalances[token] += amount;
        emit Receipt(msg.sender, amount);
    }

    function transferToken(
        IERC20 token,
        address payable to,
        uint256 amount
    ) public onlyOwner {
        require(amount <= tokenBalances[token], "Insufficient funds");

        token.transfer(to, amount);
        tokenBalances[token] -= amount;
        emit OtherReceipt(msg.sender, to, amount);
    }

    function withdrawToken(IERC20 token, uint256 amount) public onlyOwner {
        require(amount <= tokenBalances[token], "Insufficient funds");

        token.transfer(owner, amount);
        tokenBalances[token] -= amount;
        emit Receipt(msg.sender, amount);
    }
}
