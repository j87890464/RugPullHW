// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import { FiatTokenV3 } from "../src/FiatTokenV3.sol";

contract FiatTokenV3Test is Test {
    bytes32 private constant ADMIN_SLOT = keccak256("org.zeppelinos.proxy.admin");
    address public usdcOwner;
    address public user1;
    address public user2;
    address public proxyAddr;
    uint256 public mainNetFork;
    FiatTokenV3 public fiatTokenV3;
    FiatTokenV3 public proxyTokenV3;

    function bytes32ToAddress(bytes32 _bytes32) internal pure returns (address) {
        return address(uint160(uint256(_bytes32)));
    }

    function setUp() public {
        // USDC proxy contract
        proxyAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        // USDC proxy contract owner
        usdcOwner = 0x807a96288A1A408dBC13DE2b1d087d10356395d2;
        string memory mainnetUrl = vm.rpcUrl("mainnet");
        mainNetFork = vm.createFork(mainnetUrl);
        vm.selectFork(mainNetFork);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        deal(user1, 1000 ether);
        deal(user2, 1000 ether);
        vm.startPrank(usdcOwner);
        fiatTokenV3 = new FiatTokenV3();
        (bool success, ) = proxyAddr.call(
            abi.encodeWithSignature("upgradeToAndCall(address,bytes)",
            address(fiatTokenV3),
            abi.encodeWithSignature("initializeV3(address)", user1))
        );
        require(success, "upgradeToAndCall failed");
        proxyTokenV3 = FiatTokenV3(address(proxyAddr));
        vm.stopPrank();
    }

    function test_UpgradeToAndCall() public {
        vm.startPrank(usdcOwner);
        address admin = bytes32ToAddress(vm.load(proxyAddr, ADMIN_SLOT));
        assertEq(usdcOwner, admin);
        vm.expectRevert("already initialized");
        (bool success, ) = proxyAddr.call(
            abi.encodeWithSignature("upgradeToAndCall(address,bytes)",
            address(fiatTokenV3),
            abi.encodeWithSignature("initializeV3(address)", user1))
        );
        require(!success);
        vm.stopPrank();
        vm.startPrank(user1);
        assertEq(proxyTokenV3.initializeVersion(), 3);
        vm.stopPrank();
    }

    function test_V3_Mint() public {
        // user1 is in whitelist
        vm.startPrank(user1);
        // mint 1e30
        proxyTokenV3.mint(user1, 1e30);
        assertEq(proxyTokenV3.balanceOf(user1), 1e30);
        // mint 1e30
        proxyTokenV3.mint(user1, 1e30);
        assertEq(proxyTokenV3.balanceOf(user1), 2e30);
        // mint 1e30
        proxyTokenV3.mint(user1, 1e30);
        assertEq(proxyTokenV3.balanceOf(user1), 3e30);
        vm.stopPrank();

        // user2 is not in whitelist
        vm.startPrank(user2);
        vm.expectRevert("FiatToken: mint amount exceeds minterAllowance");
        proxyTokenV3.mint(user2, 1);
        vm.stopPrank();
    }

    function test_V3_Transfer() public {
        // user1 is in whitelist
        vm.startPrank(user1);
        // mint 1e18 for user1, user2
        // user1 transfer 1e18 tokens to user2 
        proxyTokenV3.mint(user1, 1e18);
        proxyTokenV3.mint(user2, 1e18);
        proxyTokenV3.transfer(user2, 1e18);
        assertEq(proxyTokenV3.balanceOf(user1), 0);
        assertEq(proxyTokenV3.balanceOf(user2), 2e18);
        proxyTokenV3.approve(user2, 1e18);
        vm.stopPrank();


        // user2 is not in whitelist
        // user2 transfer 1 token to user1
        vm.startPrank(user2);
        vm.expectRevert("You're not allowed.");
        proxyTokenV3.transfer(user1, 1);
        vm.expectRevert("You're not allowed.");
        proxyTokenV3.transferFrom(user1, user2, 1);
        proxyTokenV3.approve(user1, 2e18);
        vm.stopPrank();
        
        // transferFrom user2
        vm.startPrank(user1);
        proxyTokenV3.transferFrom(user2, user1, 2e18);
        assertEq(proxyTokenV3.balanceOf(user1), 2e18);
        assertEq(proxyTokenV3.balanceOf(user2), 0);     
        vm.stopPrank();
    }
}