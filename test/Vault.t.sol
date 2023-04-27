//SPDX-License-Identifier: UNLICESED
pragma solidity ^0.8.19;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Test} from "forge-std/Test.sol";

import {Vault} from "../src/Vault.sol";

contract SolidityDefiToken is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external {
        _burn(_from, _amount);
    }
}

contract VaultTest is Test {
    SolidityDefiToken public token;
    Vault public vault;

    function setUp() public {
        token = new SolidityDefiToken("SOLIDITY-DEFI", "SDEFI");
        vault = new Vault(address(token));
    }

    function test_Deposit() public {
        // Mint tokens
        token.mint(address(1), 1000);
        // Setting msg.sender to be address(1)
        vm.prank(address(1));
        // Approve vault contract to be able to spent tokens
        token.approve(address(vault), 1000);

        // Setting msg.sender to address(1) because its the token owner
        vm.prank(address(1));
        vault.deposit(1000);

        assertEq(vault.totalSupply(), 1000);
        // address(1) should have 1000 shares now
        assertEq(vault.balanceOf(address(1)), 1000);
    }

    // We are simulating profit generation. Assume Vault deposited the tokens to other defi
    // protocols to generate interest etc.
    function test_GenerateProfit() public {
        token.mint(address(1), 1000);
        vm.prank(address(1));
        // Approve vault contract to be able to spent tokens
        token.approve(address(vault), 1000);

        token.mint(address(1), 1000);
        vm.prank(address(1));
        // Transfer tokens directly to the Vault contract. We are simulating that another protocol
        // sending rewards to the Vault.
        token.transfer(address(vault), 1000);

        // Now Vault contract should have 2000 tokens in total
        assertEq(token.allowance(address(1), address(vault)) + token.balanceOf(address(vault)), 2 * 1000);
    }

    function test_Withdraw() public {
        token.mint(address(1), 1000);
        vm.prank(address(1));
        // Approve vault contract to be able to spent tokens
        token.approve(address(vault), 1000);

        // deposit tokens to vault
        vm.prank(address(1));
        vault.deposit(1000);

        // Mint token and send directly to vault
        token.mint(address(1), 1000);
        vm.prank(address(1));
        token.transfer(address(vault), 1000);

        vm.prank(address(1));
        vault.withdraw(1000);

        assertEq(vault.balanceOf(address(1)), 0);
        assertEq(vault.totalSupply(), 0);
        // Now address(1) should have 1000 deposited tokens + profit(which is 1000 we
        // directly transfered to vault address)
        assertEq(token.balanceOf(address(1)), 2000);
    }
}
