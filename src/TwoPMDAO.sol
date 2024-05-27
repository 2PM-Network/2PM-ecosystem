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
    mapping(bytes32 => address[]) public taskToNodeList;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier taskExists(bytes32 taskId) {
        require(taskToNodeList[taskId].length > 0, "Task does not exist");
        _;
    }

    constructor(
        address ipAssetRegistryAddr,
        address licensingModuleAddr,
        address pilTemplateAddr,
        address royaltyTokenAddr
    ) {
        TWO_PM_NFT = new TwoPMNFT("2PM IP NFT", "2PM");
        IPA_LICENSE_TOKEN = new IPALicenseToken(
            ipAssetRegistryAddr,
            licensingModuleAddr,
            pilTemplateAddr
        );
        ROYALTY_TOKEN = IMockERC20(royaltyTokenAddr);
        initialized = false;
        owner = msg.sender;
        IPA_LICENSE_TOKEN.mintLicenseToken(1, address(this));
        ROYALTY_TOKEN.mint(address(this), 100000000);
    }

    function startTrainRound(bytes32 taskId) external onlyOwner {
        nodeList = new address[](0);
        taskToNodeList[taskId] = nodeList;
    }

    function registerNode(
        bytes32 taskId,
        address node
    ) public onlyOwner taskExists(taskId) {
        taskToNodeList[taskId].push(node);
    }

    function endTrainRound(
        bytes32 taskId
    ) external onlyOwner taskExists(taskId) {
        for (uint256 i = 0; i < taskToNodeList[taskId].length; i++) {
            ROYALTY_TOKEN.transfer(taskToNodeList[taskId][i], 100000);
        }
    }

    function switchOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }
}
