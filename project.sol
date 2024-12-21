// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TuitionFeeVoucher {
    // Structure to represent a tuition fee voucher
    struct Voucher {
        uint256 id;
        address owner;
        uint256 value;
        uint256 expiryDate;
        bool redeemed;
    }

    // Mapping from voucher ID to Voucher details
    mapping(uint256 => Voucher) public vouchers;

    // Counter for generating unique voucher IDs
    uint256 private voucherCounter;

    // Owner of the contract
    address public admin;

    // Events
    event VoucherCreated(uint256 id, address owner, uint256 value, uint256 expiryDate);
    event VoucherTransferred(uint256 id, address from, address to);
    event VoucherRedeemed(uint256 id, address redeemer);

    // Modifier to restrict access to admin only
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    // Modifier to ensure voucher exists
    modifier voucherExists(uint256 id) {
        require(vouchers[id].owner != address(0), "Voucher does not exist");
        _;
    }

    // Modifier to check voucher ownership
    modifier onlyOwner(uint256 id) {
        require(vouchers[id].owner == msg.sender, "You are not the owner of this voucher");
        _;
    }

    // Constructor to initialize the contract
    constructor() {
        admin = msg.sender;
    }

    // Function to create a new voucher
    function createVoucher(address recipient, uint256 value, uint256 expiryDate) external onlyAdmin {
        require(expiryDate > block.timestamp, "Expiry date must be in the future");

        voucherCounter++;
        uint256 newVoucherId = voucherCounter;

        vouchers[newVoucherId] = Voucher({
            id: newVoucherId,
            owner: recipient,
            value: value,
            expiryDate: expiryDate,
            redeemed: false
        });

        emit VoucherCreated(newVoucherId, recipient, value, expiryDate);
    }

    // Function to transfer a voucher to another address
    function transferVoucher(uint256 id, address to) external voucherExists(id) onlyOwner(id) {
        require(to != address(0), "Cannot transfer to the zero address");
        require(!vouchers[id].redeemed, "Voucher already redeemed");

        vouchers[id].owner = to;

        emit VoucherTransferred(id, msg.sender, to);
    }

    // Function to redeem a voucher
    function redeemVoucher(uint256 id) external voucherExists(id) onlyOwner(id) {
        require(!vouchers[id].redeemed, "Voucher already redeemed");
        require(block.timestamp <= vouchers[id].expiryDate, "Voucher has expired");

        vouchers[id].redeemed = true;

        emit VoucherRedeemed(id, msg.sender);
    }

    // Function to get voucher details
    function getVoucher(uint256 id) external view voucherExists(id) returns (Voucher memory) {
        return vouchers[id];
    }
}
