// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 testVar;

    constructor() {}

    /**
     * Данная функция возвращает различные значения в
     * зависимости от значений аргумента
     * По названию можно чётко понять, что по бизнес-логике
     * наша функция не должна возвращать ноль
     *
     * Здесь довольно очевидно (в целях обучения)
     * спрятан баг, который нарушает бизнес-логику
     * этой функции.
     *
     * При помощи state-less fuzz-тестирования мы скорее всего
     * очень легко найдём этот баг
     *
     * @param x Обрабатываемое число
     */
    function NeverReturnZero(uint256 x) public pure returns (uint256) {
        if (x == 1) {
            return 123 - x;
        } else if (x % 10 == 0) {
            //Здесь всегда будет возвращаться ноль
            return (x % (78123 - 78113));
        } else if (x % 123 == 1) {
            return 321;
        } else {
            return 0;
        }
    }
    /**
     * Данная функцию уже не получится протестировать с помощью
     * state-less fuzz тестирования
     *
     * В данном случае баг вызовется только в сценарии,
     * когда состояние предыдущей итерации будет влиять на
     * состояние следующей
     *
     * Здесь на помощь может прийти только stateful
     * fuzz-тестирование
     *
     * @param x Обрабатываемое число
     */

    function NeverReturnZero2(uint256 x) public returns (uint256) {
        //
        if (x < 10) {
            revert();
        }

        if (x % 5 == 0) {
            testVar += 100;
        }

        if (testVar == 200) {
            //Может вызваться, если до этого два раза
            //вызвать функцию с аргументом, кратным 5
            return 0;
        } else {
            return 1;
        }
    }

    function increment() public {}

    receive() external payable {}
}
