// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

/**
 * Данный контракт предназначен для повышения качества
 * инвариантного тестирования и играет роль своеобразного
 * прокси, который перед вызовом функции настраивает входные данные
 * так, чтобы соблюдалась бизнес-логика проекта и не возникало лишних
 * ошибок
 */
contract Handler is Test {
    uint256 testVar;

    Counter counter;

    constructor(Counter _counter) {
        counter = _counter;
    }

    /**
     * В данной функции у нас есть только одно
     * условие в бизнес-логике:
     * входное значение должно быть больше или равно 10
     * @param x Обрабатываемое число
     */
    function neverReturnZero2(uint256 x) public returns (uint256) {
        if (x < 10) {
            counter.neverReturnZero2(x + 10);
        } else {
            counter.neverReturnZero2(x);
        }
    }
}
