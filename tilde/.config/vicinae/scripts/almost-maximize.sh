#!/usr/bin/env bash

# @vicinae.schemaVersion 1
# @vicinae.title Almost Maximize Window
# @vicinae.description Resize the active window with a small margin
# @vicinae.mode silent

set -euo pipefail

# Margin in logical pixels.
MARGIN=16

osascript -l JavaScript - "$MARGIN" <<'JXA'
ObjC.import("AppKit");

const margin = Number($.NSProcessInfo.processInfo.arguments.objectAtIndex(4).js);
const systemEvents = Application("System Events");

const processes = systemEvents.applicationProcesses.whose({
  frontmost: { "=": true },
});

if (processes.length === 0 || processes[0].windows.length === 0) {
  throw new Error("The active application has no resizable window.");
}

const window = processes[0].windows[0];
const position = window.position();
const size = window.size();

const centerX = position[0] + size[0] / 2;
const centerY = position[1] + size[1] / 2;

const mainFrame = $.NSScreen.mainScreen.frame;
const screens = $.NSScreen.screens;

let selectedScreen = $.NSScreen.mainScreen;

for (let index = 0; index < screens.count; index++) {
  const screen = screens.objectAtIndex(index);
  const frame = screen.frame;

  const left = frame.origin.x;
  const top = mainFrame.size.height - frame.origin.y - frame.size.height;
  const right = left + frame.size.width;
  const bottom = top + frame.size.height;

  if (
    centerX >= left &&
    centerX < right &&
    centerY >= top &&
    centerY < bottom
  ) {
    selectedScreen = screen;
    break;
  }
}

const visibleFrame = selectedScreen.visibleFrame;

const x = Math.round(visibleFrame.origin.x + margin);
const y = Math.round(
  mainFrame.size.height -
    visibleFrame.origin.y -
    visibleFrame.size.height +
    margin,
);

const width = Math.round(visibleFrame.size.width - margin * 2);
const height = Math.round(visibleFrame.size.height - margin * 2);

if (width <= 0 || height <= 0) {
  throw new Error("The configured margin is too large.");
}

window.position = [x, y];
window.size = [width, height];
JXA
