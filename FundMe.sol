// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    uint256 public minUsd = 50 * 1e18;
    address[] public funders;
    mapping(address => uint256) public AdddressToAmount;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        require(
            getConversionRate(msg.value) > minUsd,
            "didn't enough .. send more you fucking wanker "
        );
        funders.push(msg.sender);
        AdddressToAmount[msg.sender] = msg.value;
    }

    function getPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return priceFeed.version();
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();

        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    // withdraw

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < funders.length; i++) {
            AdddressToAmount[funders[i]] = 0;
        }
        funders = new address[](0);

        (bool res, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
        require(res, "call failed");
    }

    modifier onlyOwner() {
        require(
            owner == msg.sender,
            "you cant withdrew the money ! only owner can withdrew the money"
        );
        _;
    }
}
