// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {IPAssetRegistry} from "@storyprotocol/core/registries/IPAssetRegistry.sol";
import {LicensingModule} from "@storyprotocol/core/modules/licensing/LicensingModule.sol";
import {PILicenseTemplate} from "@storyprotocol/core/modules/licensing/PILicenseTemplate.sol";

import {TwoPMNFT} from "./TwoPMNFT.sol";

/// @notice Attach a Selected Programmable IP License Terms to an IP Account.
contract IPALicenseTerms {
    IPAssetRegistry public immutable IP_ASSET_REGISTRY;
    LicensingModule public immutable LICENSING_MODULE;
    PILicenseTemplate public immutable PIL_TEMPLATE;
    TwoPMNFT public immutable TWO_PM_NFT;

    constructor(address ipAssetRegistry, address licensingModule, address pilTemplate) {
        IP_ASSET_REGISTRY = IPAssetRegistry(ipAssetRegistry);
        LICENSING_MODULE = LicensingModule(licensingModule);
        PIL_TEMPLATE = PILicenseTemplate(pilTemplate);
        // Create a new 2PM NFT collection
        TWO_PM_NFT = new TwoPMNFT("2PM NFT", "2PM");
    }

    function attachLicenseTerms() external returns (address ipId, uint256 tokenId) {
        // First, mint an NFT and register it as an IP Account.
        // Note that first we mint the NFT to this contract for ease of attaching license terms.
        // We will transfer the NFT to the msg.sender at last.
        tokenId = TWO_PM_NFT.mint(address(this));
        ipId = IP_ASSET_REGISTRY.register(block.chainid, address(TWO_PM_NFT), tokenId);

        // Then, attach a selection of license terms from the PILicenseTemplate, which is already registered.
        // Note that licenseTermsId = 1 is a random selection of license terms already registered by another user.
        LICENSING_MODULE.attachLicenseTerms(ipId, address(PIL_TEMPLATE), 1);

        // Finally, transfer the NFT to the msg.sender.
        TWO_PM_NFT.transferFrom(address(this), msg.sender, tokenId);
    }
}
