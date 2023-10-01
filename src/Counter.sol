// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

//НЕ ИСПОЛЬЗОВАТЬ ДЛЯ РЕЛИЗА
//Импортируем console для вывода логов прямо из контракта
import {console} from "forge-std/Test.sol";

contract Counter is Ownable {
    uint256 public number;
    uint256 public lastTransferTime;

    event Incremented(uint256 indexed number);

    error ZeroNumber();

    constructor() Ownable() {
        console.log("It's Counter contract, my owner is ", owner());
    }

    /**
     * Функция для установления нового значения number
     * Доступна для вызова только owner'y
     * @param newNumber не должен быть равен 0
     */
    function setNumber(uint256 newNumber) public onlyOwner {
        if (newNumber == 0) {
            console.log("This function is going to fail!");
            revert ZeroNumber();
        }
        console.log("Setting number - ", newNumber);
        number = newNumber;
    }

    /**
     * Увеличивает значение number на 1
     * Инициирует событие Incremented
     */
    function increment() public {
        console.log("Incrementing number - ", number);
        number++;
        emit Incremented(number);
    }

    /**
     * Стандартный метод на принятие нативной валюты, выводим в лог информацию об отправителе
     * и о количестве отправленного эфира
     */
    receive() external payable {
        //Ставим ограничение по сроку пополнения баланса контракта
        require((block.timestamp >= lastTransferTime + 1 days) || lastTransferTime == 0, "Try later!");
        lastTransferTime = block.timestamp;

        console.log("Transfer  ", msg.value, " from: ", msg.sender);
    }
}
