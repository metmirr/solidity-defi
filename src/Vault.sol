//SPDX-License-Identifier: UNLICESED
pragma solidity ^0.8.19;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract Vault {
    ERC20 public immutable token;

    uint public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _token) {
        token = ERC20(_token);
    }

    function _mint(address _to, uint _amount) private {
        totalSupply += _amount;
        balanceOf[_to] = _amount;
    }

    function _burn(address _from, uint _amount) private {
        totalSupply -= _amount;
        balanceOf[_from] -= _amount;
    }

    // a = amount
    // B = balance of token before deposit (balance of the token locked inside this contract)
    // T = total supply
    // s = shares to mint
    //
    // s = (a * T) / B
    function deposit(uint _amount) external {
        uint shares;

        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }
        _mint(msg.sender, shares);
        // Transfer tokens from sender to this contract
        token.transferFrom(msg.sender, address(this), _amount);
    }

    // When we withdraw we need to calculate the amount of token for the user
    // a = amount
    // B = balance of token before withdraw (balance of the token locked inside this contract)
    // T = total supply
    // s = shares to burn
    //
    // (T - a) / T = (B - a) / B
    // a = (s * B) / T
    function withdraw(uint _shares) external {
        uint amount = (_shares * token.balanceOf(address(this))) / totalSupply;

        _burn(msg.sender, _shares);
        token.transfer(msg.sender, amount);
    }
}
