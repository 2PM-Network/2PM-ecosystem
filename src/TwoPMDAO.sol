// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {TwoPMNFT} from "./TwoPMNFT.sol";
import {IPALicenseToken} from "./IPALicenseToken.sol";
import {IMockERC20} from "./interface/IMockERC20.sol";

contract TwoPMDAO {
    TwoPMNFT public immutable TWO_PM_NFT;
    IPALicenseToken public immutable IPA_LICENSE_TOKEN;
    IMockERC20 public immutable ROYALTY_TOKEN;
    bool public initialized;
    // ownder should be contract MPC
    // (see https://github.com/2PM-Network/2PM-contracts/blob/main/contracts/Mpc.sol)
    address owner;
    address[] public nodeList;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier onlyNotInitialized() {
        require(!initialized, "DAO is already initialized");
        _;
    }

    constructor(
        address ipAssetRegistryAddr,
        address licensingModuleAddr,
        address pilTemplateAddr,
        address royaltyTokenAddr
    ) {
        TWO_PM_NFT = new TwoPMNFT("2PM IP NFT", "2PM");
        IPA_LICENSE_TOKEN = new IPALicenseToken(ipAssetRegistryAddr, licensingModuleAddr, pilTemplateAddr);
        ROYALTY_TOKEN = IMockERC20(royaltyTokenAddr);
        initialized = false;
        owner = msg.sender;
    }

    function initialize() external onlyNotInitialized onlyOwner {
        initialized = true;
        IPA_LICENSE_TOKEN.mintLicenseToken(1, address(this));
        ROYALTY_TOKEN.mint(address(this), 100000000);
    }

    function startTrainRound() external onlyOwner {
        nodeList = new address[](0);
    }

    function registerNode(address node) public onlyOwner {
        nodeList.push(node);
    }

    function endTrainRound() external onlyOwner {
        for (uint256 i = 0; i < nodeList.length; i++) {
            ROYALTY_TOKEN.transfer(nodeList[i], 100000);
        }
    }
}
