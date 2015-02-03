#!/usr/bin/env python
#
# Copyright (C) 2012 Mozilla Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# A python port of system/core/libmincrypt/tools/DumpPublicKey.java
# Dumps a C initializer for a given public key. Depends on openssl

from StringIO import StringIO
import subprocess
import sys

# http://www.algorithmist.com/index.php/Modular_inverse
def recursive_egcd(a, b):
    """Returns a triple (g, x, y), such that ax + by = g = gcd(a,b).
       Assumes a, b >= 0, and that at least one of them is > 0.
       Bounds on output values: |x|, |y| <= max(a, b)."""
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = recursive_egcd(b % a, a)
        return (g, x - (b // a) * y, y)

def modinv(a, m):
    g, x, y = recursive_egcd(a, m)
    if g != 1:
        return None
    else:
        return x % m

def write_key(key_path, out):
    modulus = subprocess.check_output(["openssl", "x509", "-in", key_path, "-modulus", "-noout"])
    N = long(modulus.replace("Modulus=", ""), 16)

    nwords = N.bit_length() / 32
    out.write("{%d" % nwords)

    B = 0x100000000L
    N0inv = B - modinv(N, B)
    out.write(",")
    out.write(hex(N0inv)[:-1])

    R = pow(2, N.bit_length())
    RR = pow(R, 2, N)
    out.write(",{")

    for i in range(0, nwords):
        n = N % B
        out.write(str(n))
        if i != nwords - 1:
            out.write(",")

        N = N / B

    out.write("},{")
    for i in range(0, nwords):
        rr = RR % B
        out.write(str(rr))
        if i != nwords - 1:
            out.write(",")

        RR = RR / B

    out.write("}}")

if __name__ == "__main__":
    result = StringIO()
    for i in range(1, len(sys.argv)):
        write_key(sys.argv[i], result)
        if i < len(sys.argv) - 1:
            result.write(",")

    print result.getvalue()
