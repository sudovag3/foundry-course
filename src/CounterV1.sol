// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * Создаём абсолютно тривиальный контракт, который может
 * доставать одну переменную из хранилища
 * и возвращать одно константное значение
 */
contract CounterV1 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    uint256 internal number;

    /// @custom:oz-upgrades-unsafe-allow constructor
    /**
     * Мы предупреждаем о том, что запускать конструктор нельзя,
     * так как мы работаем с обновляемым контрактом
     */
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init(); //делаем transferOwnership на msg.sender
        __UUPSUpgradeable_init(); // Ничего не делаем :)
    }

    function getNumber() external view returns (uint256) {
        return number;
    }

    function version() external pure returns (uint256) {
        return 1;
    }

    /**
     * Данная функция является обизательной, так как она объявлена в
     * абстрактном классе UUPSUpgradeable, но не определена
     * Здесь нам нужно лишь указать, какие ограничения мы ставим на
     * возможность обновлять наш контракт
     * В нашем случае используем onlyOwner
     * @param newImplementation адрес нового проксируемого адреса
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
