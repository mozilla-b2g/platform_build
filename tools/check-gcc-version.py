#!/usr/bin/env python

"""Check that the GCC executable (argv[1]) is of an appropriate version.
Currently, it must be no newer than 4.6.3.

"""

from __future__ import print_function

import sys
import subprocess
import traceback

newest_allowable_version = (4, 6, 3)

def usage_and_quit():
    print('Usage: %s PATH_TO_GCC' % sys.argv[0], file=sys.stderr)
    sys.exit(1)

def check_version(gcc_path):
    proc = subprocess.Popen([gcc_path, '--version'], stdout=subprocess.PIPE)
    (stdout, _) = proc.communicate()

    # versions should contain three strings, corresponding to the three version
    # numbers (e.g. ['4', '6', '2']).
    versions = stdout.split('\n')[0].split()[-1].split('.')

    version_tuple = tuple([int(v) for v in versions])

    if version_tuple > newest_allowable_version:
        print('GCC version %s is too new!  You must use GCC no newer than %s.' % \
              ('.'.join(versions),
               '.'.join([str(v) for v in newest_allowable_version])),
              file=sys.stderr)
        sys.exit(3)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        usage_and_quit()

    try:
        check_version(sys.argv[1])
    except Exception as e:
        traceback.print_exc(e)
        sys.exit(2)
