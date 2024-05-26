// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {IPAssetRegistry} from "@storyprotocol/core/registries/IPAssetRegistry.sol";
import {ISPGNFT} from "@storyprotocol/periphery/interfaces/ISPGNFT.sol";

import {IPARegistrar} from "../src/IPARegistrar.sol";
import {TwoPMNFT} from "../src/TwoPMNFT.sol";

contract IPARegistrarTest is Test {
    address internal alice = address(0xa11ce);

    // Protocol Core v1 addresses
    // (see https://docs.storyprotocol.xyz/docs/deployed-smart-contracts)
    address internal ipAssetRegistryAddr = 0xd43fE0d865cb5C26b1351d3eAf2E3064BE3276F6;
    // Protocol Periphery v1 addresses
    // (see https://github.com/storyprotocol/protocol-periphery-v1/blob/main/deploy-out/deployment-11155111.json)
    address internal storyProtocolGatewayAddr = 0x69415CE984A79a3Cfbe3F51024C63b6C107331e3;

    IPAssetRegistry public ipAssetRegistry;
    ISPGNFT public spgNft;

    IPARegistrar public ipaRegistrar;
    TwoPMNFT public twoPMnft;

    function setUp() public {
        ipAssetRegistry = IPAssetRegistry(ipAssetRegistryAddr);
        ipaRegistrar = new IPARegistrar(ipAssetRegistryAddr, storyProtocolGatewayAddr);
        twoPMnft = TwoPMNFT(ipaRegistrar.TWO_PM_NFT());
        spgNft = ISPGNFT(ipaRegistrar.SPG_NFT());

        vm.label(address(ipAssetRegistry), "IPAssetRegistry");
        vm.label(address(twoPMnft), "2PMNFT");
        vm.label(address(spgNft), "SPGNFT");
        vm.label(address(0x000000006551c19487814612e58FE06813775758), "ERC6551Registry");
    }

    function test_mintIp() public {
        uint256 expectedTokenId = twoPMnft.nextTokenId();
        address expectedIpId = ipAssetRegistry.ipId(block.chainid, address(twoPMnft), expectedTokenId);

        vm.prank(alice);
        (address ipId, uint256 tokenId) = ipaRegistrar.mintIp();

        assertEq(ipId, expectedIpId);
        assertEq(tokenId, expectedTokenId);
        assertEq(twoPMnft.ownerOf(tokenId), alice);
    }

    function test_spgMintIp() public {
        uint256 expectedTokenId = spgNft.totalSupply() + 1;
        address expectedIpId = ipAssetRegistry.ipId(block.chainid, address(spgNft), expectedTokenId);

        vm.prank(alice);
        (address ipId, uint256 tokenId) = ipaRegistrar.spgMintIp();

        assertEq(ipId, expectedIpId);
        assertEq(tokenId, expectedTokenId);
        assertEq(spgNft.ownerOf(tokenId), alice);
    }
}
