{ pkgs, homeDirectory, ... }:

{
  enable = true;

  settings = {
    positionX = "right";
    positionY = "top";
    layer = "overlay";
    control-center-layer = "overlay";
    layer-shell = true;
    cssPriority = "application";
    control-center-margin-top = 10;
    control-center-margin-bottom = 10;
    control-center-margin-right = 10;
    control-center-margin-left = 0;
    notification-2fa-action = true;
    notification-inline-replies = false;
    notification-icon-size = 48;
    notification-body-image-height = 100;
    notification-body-image-width = 200;
    timeout = 5;
    timeout-low = 3;
    timeout-critical = 0;
    fit-to-screen = true;
    control-center-width = 450;
    control-center-height = 700;
    notification-window-width = 420;
    keyboard-shortcuts = true;
    image-visibility = "when-available";
    transition-time = 250;
    hide-on-clear = false;
    hide-on-action = true;
    script-fail-notify = true;

    widgets = [
      "title"
      "dnd"
      "notifications"
    ];

    widget-config = {
      title = {
        text = "Notifications";
        clear-all-button = true;
        button-text = "Clear All";
      };
      dnd = {
        text = "Do Not Disturb";
      };
      label = {
        max-lines = 5;
        text = "Notification Center";
      };
    };
  };

  style = ''
    /* ═══════════════════════════════════════════════════
       PREMIUM NOTIFICATION DESIGN - Glassmorphism Style
       ═══════════════════════════════════════════════════ */

    * {
      all: unset;
      font-family: "Inter", "SF Pro Display", sans-serif;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }

    /* ─────────────────────────────────────────────────
       Floating Notification Window
       ───────────────────────────────────────────────── */
    .floating-notifications {
      background: transparent;
      padding: 0;
    }

    .notification-row {
      outline: none;
      margin: 8px 12px;
      animation: slideIn 0.4s cubic-bezier(0.16, 1, 0.3, 1);
    }

    @keyframes slideIn {
      from {
        opacity: 0;
        transform: translateX(100px);
      }
      to {
        opacity: 1;
        transform: translateX(0);
      }
    }

    .notification-row:hover {
      transform: translateX(-4px);
    }

    .notification-row:focus {
      outline: none;
    }

    /* ─────────────────────────────────────────────────
       Notification Card - Glassmorphism Design
       ───────────────────────────────────────────────── */
    .notification {
      background: linear-gradient(135deg,
        rgba(26, 27, 38, 0.95) 0%,
        rgba(36, 40, 59, 0.92) 100%);
      backdrop-filter: blur(20px) saturate(180%);
      -webkit-backdrop-filter: blur(20px) saturate(180%);
      border-radius: 16px;
      border: 1px solid rgba(122, 162, 247, 0.25);
      margin: 0;
      padding: 0;
      box-shadow:
        0 8px 32px rgba(0, 0, 0, 0.4),
        0 2px 8px rgba(122, 162, 247, 0.1),
        inset 0 1px 0 rgba(255, 255, 255, 0.05);
      overflow: hidden;
      position: relative;
    }

    /* Gradient accent bar on left */
    .notification::before {
      content: "";
      position: absolute;
      left: 0;
      top: 0;
      bottom: 0;
      width: 4px;
      background: linear-gradient(180deg, #7aa2f7 0%, #bb9af7 100%);
      border-radius: 16px 0 0 16px;
    }

    .notification:hover {
      border-color: rgba(122, 162, 247, 0.5);
      box-shadow:
        0 12px 48px rgba(0, 0, 0, 0.5),
        0 4px 16px rgba(122, 162, 247, 0.2),
        inset 0 1px 0 rgba(255, 255, 255, 0.1);
    }

    .notification-content {
      background: transparent;
      padding: 18px 20px 18px 24px;
      border-radius: 16px;
    }

    /* ─────────────────────────────────────────────────
       Icon & Image Styling - Premium Layout
       ───────────────────────────────────────────────── */
    .notification image {
      margin-right: 16px;
      padding: 0;
      border-radius: 12px;
      background: rgba(122, 162, 247, 0.05);
    }

    .notification .notification-icon {
      margin-right: 16px;
      padding: 8px;
      min-width: 48px;
      min-height: 48px;
      border-radius: 12px;
      background: linear-gradient(135deg,
        rgba(122, 162, 247, 0.12) 0%,
        rgba(187, 154, 247, 0.08) 100%);
      border: 1px solid rgba(122, 162, 247, 0.15);
    }

    .notification .notification-icon image {
      margin: 0;
      padding: 0;
      background: transparent;
    }

    .notification .body-image {
      margin: 12px 0 8px 0;
      border-radius: 12px;
      border: 1px solid rgba(122, 162, 247, 0.2);
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
      background: rgba(26, 27, 38, 0.5);
    }

    .notification .body-image image {
      border-radius: 12px;
      margin: 0;
    }

    /* ─────────────────────────────────────────────────
       Close Button - Minimalist & Elegant
       ───────────────────────────────────────────────── */
    .close-button {
      background: rgba(247, 118, 142, 0.15);
      color: #f7768e;
      text-shadow: none;
      padding: 0;
      border-radius: 50%;
      border: 1px solid rgba(247, 118, 142, 0.3);
      margin-top: 14px;
      margin-right: 14px;
      min-width: 28px;
      min-height: 28px;
      font-size: 16px;
      font-weight: 600;
    }

    .close-button:hover {
      background: rgba(247, 118, 142, 0.95);
      color: #1a1b26;
      border-color: #f7768e;
      transform: rotate(90deg) scale(1.05);
    }

    /* ─────────────────────────────────────────────────
       Typography - Modern Hierarchy
       ───────────────────────────────────────────────── */
    .summary {
      font-size: 15px;
      font-weight: 700;
      letter-spacing: -0.02em;
      color: #c0caf5;
      padding-bottom: 6px;
      text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
    }

    .time {
      font-size: 11px;
      font-weight: 500;
      letter-spacing: 0.02em;
      text-transform: uppercase;
      color: #565f89;
      padding-bottom: 8px;
      opacity: 0.8;
    }

    .body {
      font-size: 13.5px;
      font-weight: 400;
      line-height: 1.6;
      color: #a9b1d6;
      padding-top: 4px;
      opacity: 0.95;
    }

    /* ─────────────────────────────────────────────────
       Action Buttons
       ───────────────────────────────────────────────── */
    .notification-default-action,
    .notification-action {
      padding: 8px 12px;
      margin: 4px 0 0 0;
      background: rgba(122, 162, 247, 0.08);
      border: 1px solid rgba(122, 162, 247, 0.15);
      border-radius: 8px;
      color: #7aa2f7;
      font-size: 13px;
      font-weight: 500;
    }

    .notification-default-action:hover,
    .notification-action:hover {
      background: rgba(122, 162, 247, 0.2);
      border-color: rgba(122, 162, 247, 0.4);
      transform: translateY(-1px);
    }

    /* ─────────────────────────────────────────────────
       Control Center - Premium Panel Design
       ───────────────────────────────────────────────── */
    .control-center {
      background: linear-gradient(145deg,
        rgba(26, 27, 38, 0.98) 0%,
        rgba(36, 40, 59, 0.95) 100%);
      backdrop-filter: blur(40px) saturate(180%);
      -webkit-backdrop-filter: blur(40px) saturate(180%);
      border: 1px solid rgba(122, 162, 247, 0.2);
      border-radius: 20px;
      margin: 0;
      padding: 0;
      box-shadow:
        0 20px 60px rgba(0, 0, 0, 0.6),
        0 8px 24px rgba(0, 0, 0, 0.4),
        inset 0 1px 0 rgba(255, 255, 255, 0.05);
    }

    .control-center-list {
      background: transparent;
      padding: 8px;
    }

    .control-center-list-placeholder {
      opacity: 0.4;
      font-size: 14px;
      color: #565f89;
      padding: 40px 20px;
      text-align: center;
    }

    .blank-window {
      background: rgba(0, 0, 0, 0.15);
      backdrop-filter: blur(8px);
    }

    /* ─────────────────────────────────────────────────
       Widget Title Header
       ───────────────────────────────────────────────── */
    .widget-title {
      background: linear-gradient(135deg,
        rgba(122, 162, 247, 0.12) 0%,
        rgba(187, 154, 247, 0.08) 100%);
      margin: 16px 16px 12px 16px;
      padding: 18px 20px;
      border-radius: 14px;
      border: 1px solid rgba(122, 162, 247, 0.2);
      font-size: 17px;
      font-weight: 700;
      letter-spacing: -0.03em;
      color: #7aa2f7;
      text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
    }

    .widget-title > button {
      background: linear-gradient(135deg, #7aa2f7 0%, #89b4fa 100%);
      color: #1a1b26;
      border-radius: 10px;
      border: none;
      padding: 10px 18px;
      font-weight: 700;
      font-size: 12px;
      letter-spacing: 0.03em;
      text-transform: uppercase;
      box-shadow: 0 4px 12px rgba(122, 162, 247, 0.3);
    }

    .widget-title > button:hover {
      background: linear-gradient(135deg, #89b4fa 0%, #7dcfff 100%);
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(122, 162, 247, 0.5);
    }

    /* ─────────────────────────────────────────────────
       Do Not Disturb Toggle
       ───────────────────────────────────────────────── */
    .widget-dnd {
      background: linear-gradient(135deg,
        rgba(36, 40, 59, 0.5) 0%,
        rgba(26, 27, 38, 0.4) 100%);
      margin: 12px 16px;
      padding: 16px 20px;
      border-radius: 14px;
      border: 1px solid rgba(122, 162, 247, 0.15);
    }

    .widget-dnd > label {
      font-size: 14px;
      font-weight: 600;
      color: #c0caf5;
      letter-spacing: -0.01em;
    }

    .widget-dnd > switch {
      background: rgba(65, 72, 104, 0.6);
      border: 1px solid rgba(122, 162, 247, 0.2);
      border-radius: 100px;
      min-width: 54px;
      min-height: 30px;
      box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.3);
    }

    .widget-dnd > switch:checked {
      background: linear-gradient(135deg, #7aa2f7 0%, #89b4fa 100%);
      border-color: #7aa2f7;
      box-shadow:
        0 4px 12px rgba(122, 162, 247, 0.4),
        inset 0 1px 2px rgba(255, 255, 255, 0.3);
    }

    .widget-dnd > switch slider {
      background: linear-gradient(135deg, #e0e8ff 0%, #c0caf5 100%);
      border-radius: 50%;
      box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
      border: 1px solid rgba(255, 255, 255, 0.2);
    }

    .widget-dnd > switch:checked slider {
      background: linear-gradient(135deg, #ffffff 0%, #e0e8ff 100%);
    }

    /* ─────────────────────────────────────────────────
       Urgency-Based Styling
       ───────────────────────────────────────────────── */
    .notification.critical {
      border: 1px solid rgba(247, 118, 142, 0.6);
      box-shadow:
        0 8px 32px rgba(247, 118, 142, 0.3),
        0 2px 8px rgba(0, 0, 0, 0.4),
        inset 0 1px 0 rgba(255, 255, 255, 0.05);
    }

    .notification.critical::before {
      background: linear-gradient(180deg, #f7768e 0%, #ff7a93 100%);
    }

    .notification.critical .summary {
      color: #f7768e;
    }

    .notification.low {
      border: 1px solid rgba(86, 95, 137, 0.3);
      opacity: 0.85;
    }

    .notification.low::before {
      background: linear-gradient(180deg, #565f89 0%, #414868 100%);
    }

    .notification.normal {
      border: 1px solid rgba(122, 162, 247, 0.35);
    }

    .notification.normal::before {
      background: linear-gradient(180deg, #7aa2f7 0%, #bb9af7 100%);
    }

    /* ─────────────────────────────────────────────────
       Media Player Widget (MPRIS)
       ───────────────────────────────────────────────── */
    .widget-mpris {
      background: linear-gradient(135deg,
        rgba(187, 154, 247, 0.1) 0%,
        rgba(122, 162, 247, 0.08) 100%);
      margin: 12px 16px;
      padding: 16px;
      border-radius: 14px;
      border: 1px solid rgba(187, 154, 247, 0.2);
    }

    .widget-mpris-player {
      background: transparent;
      padding: 8px;
    }

    .widget-mpris-title {
      font-weight: 700;
      font-size: 15px;
      letter-spacing: -0.02em;
      color: #bb9af7;
      text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
    }

    .widget-mpris-subtitle {
      font-size: 13px;
      font-weight: 500;
      color: #9aa5ce;
      margin-top: 4px;
      opacity: 0.9;
    }
  '';
}
