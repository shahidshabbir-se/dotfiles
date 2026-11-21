#!/usr/bin/env python3
import select
import shutil
import signal
import sys
import termios
import time
import tty

DIGITS_LARGE = {
    "0": ["██████", "██  ██", "██  ██", "██  ██", "██████"],
    "1": ["    ██", "    ██", "    ██", "    ██", "    ██"],
    "2": ["██████", "    ██", "██████", "██    ", "██████"],
    "3": ["██████", "    ██", "██████", "    ██", "██████"],
    "4": ["██  ██", "██  ██", "██████", "    ██", "    ██"],
    "5": ["██████", "██    ", "██████", "    ██", "██████"],
    "6": ["██████", "██    ", "██████", "██  ██", "██████"],
    "7": ["██████", "    ██", "    ██", "    ██", "    ██"],
    "8": ["██████", "██  ██", "██████", "██  ██", "██████"],
    "9": ["██████", "██  ██", "██████", "    ██", "██████"],
    ":": ["      ", "  ██  ", "      ", "  ██  ", "      "],
    " ": ["      ", "      ", "      ", "      ", "      "],
}
DIGITS_COMPACT = {
    "0": ["███", "█ █", "█ █", "█ █", "███"],
    "1": ["  █", "  █", "  █", "  █", "  █"],
    "2": ["███", "  █", "███", "█  ", "███"],
    "3": ["███", "  █", "███", "  █", "███"],
    "4": ["█ █", "█ █", "███", "  █", "  █"],
    "5": ["███", "█  ", "███", "  █", "███"],
    "6": ["███", "█  ", "███", "█ █", "███"],
    "7": ["███", "  █", "  █", "  █", "  █"],
    "8": ["███", "█ █", "███", "█ █", "███"],
    "9": ["███", "█ █", "███", "  █", "███"],
    ":": ["   ", " ▄ ", "   ", " ▄ ", "   "],
    " ": ["   ", "   ", "   ", "   ", "   "],
}


def draw():
    cols, rows = shutil.get_terminal_size()
    timestr = time.strftime("%H:%M:%S")
    datestr = time.strftime("%A, %d %B %Y")
    glyphs, sep = (DIGITS_LARGE, "  ") if cols >= 70 else (DIGITS_COMPACT, " ")
    lines = [sep.join(glyphs[c][row] for c in timestr) for row in range(5)]
    start_y = max(1, (rows - 7) // 2)
    start_x = max(1, (cols - len(lines[0])) // 2)
    buf = ["\033[H\033[2J"]
    for i, line in enumerate(lines):
        y = start_y + i
        if y <= rows:
            buf.append(f"\033[{y};{start_x}H\033[1;36m{line}\033[0m")
    date_x = max(1, (cols - len(datestr)) // 2)
    date_y = start_y + 6
    if date_y <= rows:
        buf.append(f"\033[{date_y};{date_x}H\033[2;37m{datestr}\033[0m")
    sys.stdout.write("".join(buf))
    sys.stdout.flush()


def main():
    fd = sys.stdin.fileno()
    try:
        old_settings = termios.tcgetattr(fd)
    except termios.error:
        old_settings = None
    try:
        if old_settings:
            tty.setraw(fd)
        sys.stdout.write("\033[?1049h\033[?25l")
        sys.stdout.flush()
        time.sleep(0.04)
        draw()
        last_sec = int(time.time())
        last_size = shutil.get_terminal_size()
        while True:
            ready, _, _ = select.select([fd], [], [], 0.05)
            if ready:
                break
            now_sec = int(time.time())
            curr_size = shutil.get_terminal_size()
            if now_sec != last_sec or curr_size != last_size:
                last_sec, last_size = now_sec, curr_size
                draw()
    finally:
        sys.stdout.write("\033[2J\033[?1049l\033[?25h")
        sys.stdout.flush()
        if old_settings:
            try:
                termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
            except termios.error:
                pass


if __name__ == "__main__":
    def sig_handler(signum, frame):
        sys.exit(0)

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
