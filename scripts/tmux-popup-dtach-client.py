#!/usr/bin/env python3
"""Attach to dtach, but close the popup on Ctrl-b Ctrl-e."""

import os
import pty
import select
import signal
import subprocess
import sys
import termios
import tty
import fcntl

CTRL_B = b"\x02"
CTRL_E = b"\x05"
PREFIX_TIMEOUT = 0.7


def copy_size(src_fd, dst_fd):
    try:
        size = fcntl.ioctl(src_fd, termios.TIOCGWINSZ, b"\0" * 8)
        fcntl.ioctl(dst_fd, termios.TIOCSWINSZ, size)
    except OSError:
        pass


def write_all(fd, data):
    while data:
        written = os.write(fd, data)
        data = data[written:]


def main():
    if len(sys.argv) != 3:
        print("usage: tmux-popup-dtach-client.py DTACH SOCKET", file=sys.stderr)
        return 2

    dtach, socket = sys.argv[1:]
    stdin_fd = sys.stdin.fileno()
    stdout_fd = sys.stdout.fileno()
    old_tty = termios.tcgetattr(stdin_fd)
    master_fd, slave_fd = pty.openpty()

    copy_size(stdout_fd, slave_fd)
    proc = subprocess.Popen(
        [dtach, "-a", socket],
        stdin=slave_fd,
        stdout=slave_fd,
        stderr=slave_fd,
        close_fds=True,
        preexec_fn=os.setsid,
    )
    os.close(slave_fd)

    done = False

    def stop(*_):
        nonlocal done
        done = True

    def resize(*_):
        copy_size(stdout_fd, master_fd)
        try:
            os.killpg(proc.pid, signal.SIGWINCH)
        except ProcessLookupError:
            pass

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGHUP, stop)
    signal.signal(signal.SIGWINCH, resize)

    pending_prefix = False
    try:
        tty.setraw(stdin_fd)
        while not done and proc.poll() is None:
            timeout = PREFIX_TIMEOUT if pending_prefix else None
            readable, _, _ = select.select([stdin_fd, master_fd], [], [], timeout)

            if pending_prefix and not readable:
                write_all(master_fd, CTRL_B)
                pending_prefix = False
                continue

            for fd in readable:
                try:
                    data = os.read(fd, 4096)
                except OSError:
                    done = True
                    break

                if not data:
                    done = True
                    break

                if fd == master_fd:
                    write_all(stdout_fd, data)
                    continue

                for byte in data:
                    char = bytes([byte])
                    if pending_prefix:
                        if char == CTRL_E:
                            done = True
                            break
                        write_all(master_fd, CTRL_B + char)
                        pending_prefix = False
                    elif char == CTRL_B:
                        pending_prefix = True
                    else:
                        write_all(master_fd, char)
    finally:
        termios.tcsetattr(stdin_fd, termios.TCSADRAIN, old_tty)
        if proc.poll() is None:
            try:
                os.killpg(proc.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
        try:
            os.close(master_fd)
        except OSError:
            pass

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
