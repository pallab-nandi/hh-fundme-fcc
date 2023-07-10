// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConvertor.sol";

error Unauthorized();
error TransactionFailed();

/**
 * @title A crowd funding demo contract
 * @author Pallab Nandi
 * @notice This is a simple testing demo for a smart contract
 * @dev Implementation of price feed follows our library
 */

contract FundMe {
    using PriceConvertor for uint256;

    uint256 public constant minUSD = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmount;

    address public immutable owner;

    AggregatorV3Interface public priceFeed;

    constructor(address priceFeedAddress) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    modifier onlyOwner() {
        // require(msg.sender == owner, "Not an owner");
        if (msg.sender != owner) {
            revert Unauthorized();
        }
        _;
    }

    function fund() public payable {
        // Want to be able to set a minimum fund amount in USD
        // require(msg.value.getConversionRate() >= minUSD, "Didn't send enough!"); // 1e18 == 1 * 10 ** 18
        if (msg.value.getConversionRate(priceFeed) < minUSD) {
            revert TransactionFailed();
        }
        funders.push(msg.sender);
        addressToAmount[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmount[funder] = 0;
        }

        // reset array
        funders = new address[](0);

        // withdraw the amount from the contract

        /*
        // transfer
        payable(msg.sender).transfer(address(this).balance);

        // send
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send failed!");
        */

        // call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        // require(callSuccess, "Call Failed!");
        if (!callSuccess) {
            revert TransactionFailed();
        }

        // msg.sender -> address
        // payable(msg.sender) -> payable address
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
