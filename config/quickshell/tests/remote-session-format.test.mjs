import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";
import vm from "node:vm";

const source = readFileSync(
    new URL("../plugins/remoteSession/RemoteSession.js", import.meta.url),
    "utf8"
);
const context = {};
vm.createContext(context);
vm.runInContext(source, context);

test("parseLogind reads key/value lines", () => {
    const parsed = context.parseLogind(
        "Remote=no\nType=wayland\nClass=user\nService=hyprland\n"
    );
    assert.deepEqual(
        JSON.parse(JSON.stringify(parsed)),
        {
            Remote: "no",
            Type: "wayland",
            Class: "user",
            Service: "hyprland"
        }
    );
});

test("a local wayland session is not remote", () => {
    assert.deepEqual(
        JSON.parse(JSON.stringify(context.classify({
            display: ":1",
            waylandDisplay: "wayland-1",
            remoteFlag: "no",
            sessionType: "wayland",
            sessionClass: "user"
        }))),
        { remote: false, reason: "local" }
    );
});

test("SSH environment wins over logind", () => {
    assert.deepEqual(
        JSON.parse(JSON.stringify(context.classify({
            sshConnection: "1.2.3.4 1234 10.0.0.1 22",
            remoteFlag: "no",
            sessionType: "tty"
        }))),
        { remote: true, reason: "ssh" }
    );
});

test("logind Remote=yes and sshd service are remote", () => {
    assert.equal(context.classify({ remoteFlag: "yes" }).reason, "logind");
    assert.equal(context.classify({ service: "sshd" }).reason, "logind-service");
});

test("x11 display hosts are distinguished from local displays", () => {
    assert.equal(context.classify({ display: "displayhost:0" }).reason, "x11-display");
    assert.equal(context.classify({ display: "unix:0" }).remote, false);
    assert.equal(context.classify({ display: ":0" }).remote, false);
    assert.equal(context.classify({ display: "localhost:0" }).remote, false);
});

test("a TTY session with no display is remote", () => {
    assert.deepEqual(
        JSON.parse(JSON.stringify(context.classify({ sessionType: "tty" }))),
        { remote: true, reason: "tty" }
    );
});

test("statusObject carries the observable fields", () => {
    const status = context.statusObject({
        sshConnection: "1.2.3.4 1234 10.0.0.1 22",
        sessionId: "3",
        sessionType: "tty",
        sessionClass: "user",
        display: ""
    });
    assert.equal(status.remote, true);
    assert.equal(status.reason, "ssh");
    assert.equal(status.summary, "remote session (ssh)");
    assert.equal(status.sessionId, "3");
    assert.equal(status.sessionType, "tty");
});
