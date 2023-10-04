// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract CounterV2 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    uint256 internal value;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    /**
     * Добавляем новую функцию, чтобы проверять корректность
     * работы апргрейда
     */
    function increment() public {
        value++;
    }

    function getValue() public view returns (uint256) {
        return value;
    }

    /**
     * Меняем версию на актуальную
     */
    function version() public pure returns (uint256) {
        return 2;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
