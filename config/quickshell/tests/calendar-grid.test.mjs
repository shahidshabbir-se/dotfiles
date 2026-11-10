import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";
import vm from "node:vm";

const source = readFileSync(
    new URL("../plugins/clock/Calendar.js", import.meta.url),
    "utf8"
);
const context = {};
vm.createContext(context);
vm.runInContext(source, context);

test("date keys zero-pad month and day", () => {
    assert.equal(context.dateKey(new Date(2026, 0, 5, 12)), "2026-01-05");
    assert.equal(context.dateKey(new Date(2026, 10, 30, 12)), "2026-11-30");
    assert.equal(context.monthKey(new Date(2026, 0, 5, 12)), "2026-01");
});

test("startOfMonth normalizes the day and time", () => {
    const month = context.startOfMonth(new Date(2026, 4, 20, 18, 30));
    assert.equal(month.getFullYear(), 2026);
    assert.equal(month.getMonth(), 4);
    assert.equal(month.getDate(), 1);
    assert.equal(month.getHours(), 12);
});

test("shiftMonth crosses year boundaries", () => {
    const january = new Date(2026, 0, 1, 12);
    const december = context.shiftMonth(january, -1);
    assert.equal(december.getFullYear(), 2025);
    assert.equal(december.getMonth(), 11);

    const next = context.shiftMonth(december, 2);
    assert.equal(next.getFullYear(), 2026);
    assert.equal(next.getMonth(), 1);
});

test("monthLabel names the month and year", () => {
    assert.equal(context.monthLabel(new Date(2026, 10, 1, 12)), "November 2026");
});

test("grid starts on Monday and marks the current month and today", () => {
    const month = new Date(2026, 0, 1, 12);
    const today = new Date(2026, 0, 15, 9, 0);
    const cells = Array.from(context.buildGrid(month, today), cell => [
        cell.key,
        cell.day,
        cell.inMonth,
        cell.isToday
    ]);

    assert.equal(cells.length, 42);
    // 1 January 2026 is a Thursday, so Monday-first needs three leading cells.
    assert.deepEqual(cells[0], ["2025-12-29", 29, false, false]);
    assert.deepEqual(cells[3], ["2026-01-01", 1, true, false]);
    assert.deepEqual(cells[17], ["2026-01-15", 15, true, true]);

    const inMonthDays = cells.filter(cell => cell[2]).map(cell => cell[1]);
    assert.deepEqual(inMonthDays, Array.from({ length: 31 }, (_, i) => i + 1));
});

test("grid handles a leap February", () => {
    const month = new Date(2024, 1, 1, 12);
    const cells = Array.from(context.buildGrid(month, month), cell => [
        cell.day,
        cell.inMonth
    ]);
    const inMonthDays = cells.filter(cell => cell[1]).map(cell => cell[0]);

    assert.equal(inMonthDays.length, 29);
    assert.equal(inMonthDays[28], 29);
});
