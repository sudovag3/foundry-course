// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Counter is Ownable {
    uint256 public number;

    event Incremented(uint256 indexed number);

    error ZeroNumber();

    constructor() Ownable() {}

    /**
     * Функция для установления нового значения number
     * Доступна для вызова только owner'y
     * @param newNumber не должен быть равен 0
     */
    function setNumber(uint256 newNumber) public onlyOwner {
        if (newNumber == 0) {
            revert ZeroNumber();
        }
        number = newNumber;
    }

    /**
     * Увеличивает значение number на 1
     * Инициирует событие Incremented
     */
    function increment() public {
        number++;
        emit Incremented(number);
    }
}
