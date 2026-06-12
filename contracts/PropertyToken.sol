// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title PropertyToken
 * @dev ERC-1400 compliant security token for tokenized real estate
 * @author Andrew Elston | github.com/BlockchainNooberz
 */

interface IERC1400 {
    function transferWithData(address to, uint256 value, bytes calldata data) external;
    function transferFromWithData(address from, address to, uint256 value, bytes calldata data) external;
    function isControllable() external view returns (bool);
    function isIssuable() external view returns (bool);
}

contract PropertyToken {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    address public issuer;
    string public propertyAddress;
    uint256 public propertyValueUSD;

    mapping(address => uint256) public balances;
    mapping(address => bool) public whitelisted;

    event TokensIssued(address indexed to, uint256 amount);
    event DividendDistributed(uint256 totalAmount, uint256 perTokenAmount);
    event InvestorWhitelisted(address indexed investor);

    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only issuer");
        _;
    }

    modifier onlyWhitelisted(address account) {
        require(whitelisted[account], "Not whitelisted");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _propertyAddress,
        uint256 _propertyValueUSD,
        uint256 _totalSupply
    ) {
        name = _name;
        symbol = _symbol;
        propertyAddress = _propertyAddress;
        propertyValueUSD = _propertyValueUSD;
        totalSupply = _totalSupply;
        issuer = msg.sender;
    }

    function whitelistInvestor(address investor) external onlyIssuer {
        whitelisted[investor] = true;
        emit InvestorWhitelisted(investor);
    }

    function issueTokens(address to, uint256 amount) external onlyIssuer onlyWhitelisted(to) {
        balances[to] += amount;
        emit TokensIssued(to, amount);
    }

    function distributeDividend() external payable onlyIssuer {
        require(totalSupply > 0, "No tokens");
        uint256 perToken = msg.value / totalSupply;
        emit DividendDistributed(msg.value, perToken);
    }
}
