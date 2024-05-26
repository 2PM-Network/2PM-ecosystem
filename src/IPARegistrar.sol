// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {IPAssetRegistry} from "@storyprotocol/core/registries/IPAssetRegistry.sol";
import {StoryProtocolGateway} from "@storyprotocol/periphery/StoryProtocolGateway.sol";
import {IStoryProtocolGateway as ISPG} from "@storyprotocol/periphery/interfaces/IStoryProtocolGateway.sol";
import {SPGNFT} from "@storyprotocol/periphery/SPGNFT.sol";

import {TwoPMNFT} from "./TwoPMNFT.sol";

/// @notice Register an NFT as an IP Account.
contract IPARegistrar {
    IPAssetRegistry public immutable IP_ASSET_REGISTRY;
    StoryProtocolGateway public immutable SPG;
    TwoPMNFT public immutable TWO_PM_NFT;
    SPGNFT public immutable SPG_NFT;

    constructor(address ipAssetRegistry, address storyProtocolGateway) {
        IP_ASSET_REGISTRY = IPAssetRegistry(ipAssetRegistry);
        SPG = StoryProtocolGateway(storyProtocolGateway);
        // Create a new 2PM NFT collection
        TWO_PM_NFT = new TwoPMNFT("2PM NFT", "2PM");
        // Create a new NFT collection via SPG
        SPG_NFT = SPGNFT(
            SPG.createCollection({
                name: "SPG IP NFT",
                symbol: "SPIN",
                maxSupply: 10000,
                mintFee: 0,
                mintFeeToken: address(0),
                owner: address(this)
            })
        );
    }

    /// @notice Mint an IP NFT and register it as an IP Account via Story Protocol core.
    /// @return ipId The address of the IP Account.
    /// @return tokenId The token ID of the IP NFT.
    function mintIp() external returns (address ipId, uint256 tokenId) {
        tokenId = TWO_PM_NFT.mint(msg.sender);
        ipId = IP_ASSET_REGISTRY.register(block.chainid, address(TWO_PM_NFT), tokenId);
    }

    /// @notice Mint an IP NFT and register it as an IP Account via Story Protocol Gateway (periphery).
    /// @dev Requires the collection to be created via SPG (createCollection).
    function spgMintIp() external returns (address ipId, uint256 tokenId) {
        (ipId, tokenId) = SPG.mintAndRegisterIp(
            address(SPG_NFT),
            msg.sender,
            ISPG.IPMetadata({
                metadataURI: "ip-metadata-uri",
                metadataHash: keccak256("ip-metadata-uri-content"),
                nftMetadataHash: keccak256("nft-metadata-uri-content")
            })
        );
    }
}
