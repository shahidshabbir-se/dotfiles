import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";
import vm from "node:vm";

const source = readFileSync(
    new URL("../plugins/notifications/Format.js", import.meta.url),
    "utf8"
);
const context = {};
vm.createContext(context);
vm.runInContext(source, context);

test("cleanSingleLine flattens controls and truncates", () => {
    assert.equal(context.cleanSingleLine("  hello  ", 20), "hello");
    assert.equal(context.cleanSingleLine("a\nb", 20), "a b");
    assert.equal(context.cleanSingleLine("abcdef", 4), "abcd");
    assert.equal(context.cleanSingleLine("a\u202eb", 20), "ab");
});

test("cleanBody keeps line breaks and strips unsafe controls", () => {
    assert.equal(context.cleanBody("line1\nline2\r\nline3"), "line1\nline2\nline3");
    assert.equal(context.cleanBody("a\u0000b"), "a b");
    assert.equal(context.cleanBody("a\u2028b"), "a\nb");
    assert.equal(context.cleanBody("x".repeat(5000)).length, 4096);
});

test("safeIconName only accepts theme icon names", () => {
    assert.equal(context.safeIconName("utilities-terminal"), "utilities-terminal");
    assert.equal(context.safeIconName("bad icon"), "");
    assert.equal(context.safeIconName("../../x"), "");
});

test("iconSource prefers the app icon and resolves file/URL paths", () => {
    const resolver = name => "/icons/" + name;
    assert.equal(
        context.iconSource("dialog-information", "/tmp/image.png", resolver),
        "/icons/dialog-information"
    );
    assert.equal(
        context.iconSource("", "/tmp/image.png", resolver),
        "file:///tmp/image.png"
    );
    assert.equal(
        context.iconSource("", "https://example.test/image.png", resolver),
        "https://example.test/image.png"
    );
    assert.equal(
        context.iconSource("bad icon", "/tmp/image.png", resolver),
        "file:///tmp/image.png"
    );
    assert.equal(context.iconSource("dialog-info", "", resolver), "/icons/dialog-info");
    assert.equal(context.iconSource("dialog-info", "", undefined), "");
});

test("visibleToasts returns newest first and caps the stack", () => {
    assert.deepEqual(Array.from(context.visibleToasts([1, 2, 3], 2)), [3, 2]);
    assert.deepEqual(Array.from(context.visibleToasts([], 4)), []);
    assert.deepEqual(Array.from(context.visibleToasts([1, 2, 3], 0)), [3, 2, 1]);
});

test("overflowedToasts expires oldest entries beyond the cap", () => {
    assert.deepEqual(Array.from(context.overflowedToasts([1, 2, 3, 4, 5], 3)), [1, 2]);
    assert.deepEqual(Array.from(context.overflowedToasts([1, 2], 3)), []);
    assert.deepEqual(Array.from(context.overflowedToasts([], 3)), []);
});

test("toastTimeout honours server and critical expiry rules", () => {
    assert.equal(context.toastTimeout(-1, false, 6000), 6000);
    assert.equal(context.toastTimeout(0, false, 6000), 0);
    assert.equal(context.toastTimeout(0, true, 6000), 0);
    assert.equal(context.toastTimeout(500, false, 6000), 1000);
    assert.equal(context.toastTimeout(45000, false, 6000), 30000);
    assert.equal(context.toastTimeout(2000, false, 6000), 2000);
});

test("actionList filters empty labels and caps buttons", () => {
    const actions = [
        { identifier: "default", text: "Open" },
        { identifier: "ignore", text: "  " },
        { identifier: "reply", text: "Reply" },
        { identifier: "later", text: "Later" },
        { identifier: "fourth", text: "Fourth" },
    ];
    assert.deepEqual(
        Array.from(context.actionList(actions, 3), action => action.text),
        ["Open", "Reply", "Later"]
    );
    assert.deepEqual(Array.from(context.actionList([null, { text: "" }], 3)), []);
});
