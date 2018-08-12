#!/usr/bin/env python

import re
import socket
import subprocess
from datetime import datetime
from functools import wraps
from os import getenv, getcwd, devnull, environ
from os.path import basename


DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S'
DEVNULL = open(devnull, 'w')
environ['VIRTUAL_ENV_DISABLE_PROMPT'] = '1'


class Colors(object):
    BLACK = 30
    RED = 31
    GREEN = 32
    BROWN = 33
    BLUE = 34
    PURPLE = 35
    CYAN = 36
    GRAY = 37


def ignore_errors(f):
    @wraps(f)
    def decorator(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except:
            raise
            return ''

    return decorator


class Git(object):
    BRANCH_PATTERN = re.compile(r'On branch ([^\s]+)', re.MULTILINE)
    DETACHED_PATTERN = re.compile(r'HEAD detached at ([^\s]+)', re.MULTILINE)

    @classmethod
    @ignore_errors
    def status(cls):
        status = subprocess.check_output(
            ['git', 'status'], stderr=DEVNULL).decode('utf-8')
        color, dirty = cls._current_color(status)
        branch = cls._current_branch(status)
        text = '({}{})'.format(branch, ' *' if dirty else '')

        return colorize(text, color)

    @classmethod
    def _current_color(cls, status):
        if 'working tree clean' not in status:
            return Colors.RED, True
        if 'Your branch is ahead of' in status:
            return Colors.BROWN, False
        if 'nothing to commit' in status:
            return Colors.GREEN, False
        return Colors.PURPLE, False

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
        text = '{}@{}'.format(namespace, context)
        return colorize(text, Colors.PURPLE)

    @classmethod
    def _current_context(cls):
        return subprocess.check_output([
            'kubectl', 'config', 'current-context'
        ]).decode('utf-8').strip()

    @classmethod
    def _current_namespace(cls):
        contexts = subprocess.check_output([
            'kubectl', 'config', 'get-contexts'
        ]).decode('utf-8').strip().split('\n')[1:]

        for context_line in contexts:
            parts = cls.SPACES_PATTERN.split(context_line.strip())
            if len(parts) == 5 and parts[0] == '*':
                return parts[4]

        return '?'


class VirtualEnv(object):
    @classmethod
    @ignore_errors
    def status(cls):
        current = cls._current_env()
        if current:
            return colorize(current, Colors.BLUE, light=True)

    @classmethod
    def _current_env(cls):
        current = getenv('VIRTUAL_ENV')
        if current:
            return basename(current)


class Prompt(object):
    @classmethod
    def now(cls):
        text = datetime.now().strftime(DATETIME_FORMAT)
        return colorize(text, Colors.GREEN, light=True)

    @classmethod
    def who(cls):
        text = '{}@{}:'.format(getenv('USER'), socket.gethostname())
        return colorize(text, Colors.BROWN)

    @classmethod
    def directory(cls):
        wd = getcwd()
        home = getenv('HOME')
        if home in wd:
            wd = wd.replace(home, '~')
        text = '{}:'.format(wd)
        return colorize(text, Colors.CYAN)

    @classmethod
    def git(cls):
        return Git.status()

    @classmethod
    def kube(cls):
        return Kube.status()

    @classmethod
    def virtualenv(cls):
        return VirtualEnv.status()


def colorize(text, color, light=False):
    light = int(light)
    return '\033[{light};{color}m{text}\033[0m'.format(
        **locals()
    )


def create_prompt(parts):
    return ' '.join(p for p in parts if p) + ' '


def main():
    parts = [
        Prompt.now(),
        Prompt.git(),
        Prompt.kube(),
        Prompt.virtualenv(),
        Prompt.who(),
        Prompt.directory(),
    ]

    print(create_prompt(parts))


if __name__ == '__main__':
    main()
