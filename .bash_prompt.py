#!/usr/bin/env python3

import re
import socket
import subprocess
from datetime import datetime
from functools import wraps
from os import getenv, getcwd, geteuid, devnull, environ
from os.path import basename

DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S'
DEVNULL = open(devnull, 'w')


class Colors(object):
    DEFAULT = 39
    BLACK = 30
    RED = 31
    GREEN = 32
    YELLOW = 33
    BLUE = 34
    MAGENTA = 35
    CYAN = 36
    GRAY = 37


def ignore_errors(f):
    @wraps(f)
    def decorator(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except:
            return ''

    return decorator


class Git(object):
    BRANCH_PATTERN = re.compile(r'On branch ([^\s]+)', re.MULTILINE)
    DETACHED_PATTERN = re.compile(r'HEAD detached at ([^\s]+)', re.MULTILINE)

    @classmethod
    @ignore_errors
    def status(cls, auto_color=True, *args, **kwargs):
        status = subprocess.check_output(
            ['git', 'status'], stderr=DEVNULL).decode('utf-8')
        color, dirty = cls._current_color(status)
        branch = cls._current_branch(status)
        text = '{}{}'.format(branch, ' *' if dirty else '')

        if not auto_color:
            color = Colors.DEFAULT

        return stylize(text, color, *args, **kwargs)

    @classmethod
    def _current_color(cls, status):
        if 'working tree clean' not in status:
            return Colors.RED, True
        if 'Your branch is ahead of' in status:
            return Colors.YELLOW, False
        if 'nothing to commit' in status:
            return Colors.GREEN, False
        return Colors.MAGENTA, False

    @classmethod
    def _current_branch(cls, status):
        branch_match = cls.BRANCH_PATTERN.match(status)
        detached_math = cls.DETACHED_PATTERN.match(status)

        if branch_match:
            return branch_match.group(1)
        if detached_math:
            return detached_math.group(1)
        return ''


class Kube(object):
    SPACES_PATTERN = re.compile(r'\s+')

    @classmethod
    @ignore_errors
    def status(cls):
        context = cls._current_context()
        namespace = cls._current_namespace()
        return '{}@{}'.format(namespace, context)

    @classmethod
    def _current_context(cls):
        return subprocess.check_output([
            'kubectl', 'config', 'current-context'
        ], stderr=DEVNULL).decode('utf-8').strip()

    @classmethod
    def _current_namespace(cls):
        contexts = subprocess.check_output([
            'kubectl', 'config', 'get-contexts'
        ], stderr=DEVNULL).decode('utf-8').strip().split('\n')[1:]

        for context_line in contexts:
            parts = cls.SPACES_PATTERN.split(context_line.strip())
            if len(parts) == 5 and parts[0] == '*':
                return parts[4]

        return '?'


class VirtualEnv(object):
    @classmethod
    @ignore_errors
    def status(cls):
        current = getenv('VIRTUAL_ENV')
        if current:
            return basename(current)


class Prompt(object):
    @classmethod
    def now(cls):
        return datetime.now().strftime(DATETIME_FORMAT)

    @classmethod
    def who(cls):
        return '{}@{}'.format(getenv('USER'), socket.gethostname())

    @classmethod
    def directory(cls):
        wd = getcwd()
        home = getenv('HOME')
        if home in wd:
            wd = wd.replace(home, '~')
        return '{}'.format(wd)

    @classmethod
    def prompt_end(cls):
        uid = geteuid()
        if uid == 0:
            return '#'
        return '$'


def stylize(text, color, light=False, bold=False, dim=False, underline=False,
            blink=False, reverse=False, hidden=False):
    if not text:
        return

    if light:
        color += 60
    styles = [color]
    if bold:
        styles.append(1)
    if dim:
        styles.append(2)
    if underline:
        styles.append(4)
    if blink:
        styles.append(5)
    if reverse:
        styles.append(7)
    if hidden:
        styles.append(8)

    styles = ';'.join(str(style) for style in styles)
    esc_start = '\['
    esc_end = '\]'
    template = (
        '{esc_start}'
        '\033[{styles}m'
        '{esc_end}'
        '{text}'
        '{esc_start}'
        '\033[0m'
        '{esc_end}'
    )
    return template.format(
        **locals()
    )


def create_prompt(parts, separator=' '):
    return separator.join(p for p in parts if p) + ' '


def main():
    parts = [
        stylize(Prompt.now(), Colors.GREEN, reverse=True),
        Git.status(auto_color=True, bold=True),
        stylize(Kube.status(), Colors.MAGENTA, bold=True),
        stylize(VirtualEnv.status(), Colors.BLUE, light=True, bold=True),
        stylize(Prompt.who(), Colors.YELLOW, dim=True),
        stylize(Prompt.directory(), Colors.CYAN),
        stylize('\n', Colors.GRAY, light=True),
        stylize(Prompt.prompt_end(), Colors.GRAY, light=True),
    ]

    print(create_prompt(parts))


if __name__ == '__main__':
    main()
