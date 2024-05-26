// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {LicenseToken} from "@storyprotocol/core/LicenseToken.sol";
import {IPAssetRegistry} from "@storyprotocol/core/registries/IPAssetRegistry.sol";

import {IPALicenseToken} from "../src/IPALicenseToken.sol";
import {TwoPMNFT} from "../src/TwoPMNFT.sol";

contract IPALicenseTokenTest is Test {
    address internal alice = address(0xa11ce);
    address internal bob = address(0xb0b);

    // Protocol Core v1 addresses
    // (see https://docs.storyprotocol.xyz/docs/deployed-smart-contracts)
    address internal ipAssetRegistryAddr = 0xd43fE0d865cb5C26b1351d3eAf2E3064BE3276F6;
    address internal licensingModuleAddr = 0xe89b0EaA8a0949738efA80bB531a165FB3456CBe;
    address internal licenseTokenAddr = 0x1333c78A821c9a576209B01a16dDCEF881cAb6f2;
    address internal pilTemplateAddr = 0x260B6CB6284c89dbE660c0004233f7bB99B5edE7;

    IPAssetRegistry public ipAssetRegistry;
    LicenseToken public licenseToken;

    IPALicenseToken public ipaLicenseToken;
    TwoPMNFT public twopmNFT;

    function setUp() public {
        ipAssetRegistry = IPAssetRegistry(ipAssetRegistryAddr);
        licenseToken = LicenseToken(licenseTokenAddr);
        ipaLicenseToken = new IPALicenseToken(ipAssetRegistryAddr, licensingModuleAddr, pilTemplateAddr);
        twopmNFT = TwoPMNFT(ipaLicenseToken.TWO_PM_NFT());

        vm.label(address(ipAssetRegistryAddr), "IPAssetRegistry");
        vm.label(address(licensingModuleAddr), "LicensingModule");
        vm.label(address(licenseTokenAddr), "LicenseToken");
        vm.label(address(pilTemplateAddr), "PILicenseTemplate");
        vm.label(address(twopmNFT), "TWO PM NFT");
        vm.label(address(0x000000006551c19487814612e58FE06813775758), "ERC6551Registry");
    }

    function test_mintLicenseToken() public {
        uint256 expectedTokenId = twopmNFT.nextTokenId();
        address expectedIpId = ipAssetRegistry.ipId(block.chainid, address(twopmNFT), expectedTokenId);

        vm.prank(alice);
        (address ipId, uint256 tokenId, uint256 startLicenseTokenId) =
            ipaLicenseToken.mintLicenseToken({ltAmount: 2, ltRecipient: bob});

        assertEq(ipId, expectedIpId);
        assertEq(tokenId, expectedTokenId);
        assertEq(twopmNFT.ownerOf(tokenId), alice);

        assertEq(licenseToken.ownerOf(startLicenseTokenId), bob);
        assertEq(licenseToken.ownerOf(startLicenseTokenId + 1), bob);
    }
}
