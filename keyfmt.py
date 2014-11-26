#!/usr/bin/env python
#
# Read a private key from stdin and output formatted data values.
# Input one key per line either hex (64 chars) or WIF key (51 base 58 chars).
#
# The format argument can contain variables:
#
# %h = HEX privkey
# %w = WIF privkey
# %p = public key
# %a = address
#
# eg. "Address: %a\nPrivkey: %w" outputs a format like the vanitygen program
#     "a:%w" outputs a format good for importing to Electrum
# 
# This generates a new key for importing to Electrum:
#
#     hexdump -v -e '/1 "%02X"' -n 32 /dev/urandom | keyfmt "%a:%w"
#

import sys, binascii, hashlib

if len(sys.argv) < 2:
        print "Usage: %s <format string>\n\nRead a hex private key from stdin and output formatted data.\n" % sys.argv[0]
        print "These variables are supported:\n%h = HEX privkey\n%w = WIF privkey\n%p = public key\n%a = address\n" 
        print "eg. 'Address: %a\\nPrivkey: %w' outputs a format like the vanitygen program\n"
        sys.exit(1)

alphabet="123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
advanced = any(v in sys.argv[1] for v in ['%p', '%a'])

def b58encode(num, pad=''):
        out = ''
        while num >= 58:
                num,m = divmod(num, 58)
                out = alphabet[m] + out
        return pad + alphabet[num] + out

def b58hex(s58):
        num = 0L
        for (i, c) in enumerate(s58[::-1]):
                num += alphabet.find(c) * (58**i)
        return hex(num)[4:-9].upper()
        
if advanced:
        import ecdsa

        # secp256k1, http://www.oid-info.com/get/1.3.132.0.10
        _p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2FL
        _r = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141L
        _b = 0x0000000000000000000000000000000000000000000000000000000000000007L
        _a = 0x0000000000000000000000000000000000000000000000000000000000000000L
        _Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798L
        _Gy = 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8L
        curve_secp256k1 = ecdsa.ellipticcurve.CurveFp( _p, _a, _b )
        generator_secp256k1 = ecdsa.ellipticcurve.Point( curve_secp256k1, _Gx, _Gy, _r )
        oid_secp256k1 = (1,3,132,0,10)
        SECP256k1 = ecdsa.curves.Curve("SECP256k1", curve_secp256k1, generator_secp256k1, oid_secp256k1 ) 

for line in sys.stdin:
        line = line.replace(' ', '')
        line = b58hex(line[:51]) if line[0] == '5' and len(line) < 64 else line[:64]
        chksum = binascii.hexlify(hashlib.sha256(hashlib.sha256(binascii.unhexlify('80'+line)).digest()).digest()[:4])
        privkey = long('80'+line+chksum, 16)
        
        if advanced:
                pubkey = chr(4) + ecdsa.SigningKey.from_secret_exponent(long(line, 16), curve=SECP256k1 ).get_verifying_key().to_string()
                pad = ""
                rmd = hashlib.new('ripemd160')
                rmd.update(hashlib.sha256(pubkey).digest())
                an = chr(0) + rmd.digest()
                for c in an:
                        if c == '\0': pad += '1'
                        else: break
                addr = long(binascii.hexlify(an + hashlib.sha256(hashlib.sha256(an).digest()).digest()[0:4]), 16)
        
        out = sys.argv[1].replace('%h', line).replace('%w', b58encode(privkey))
        if advanced:
                out = out.replace('%p', binascii.hexlify(pubkey).upper()).replace('%a', b58encode(addr, pad))
        print out.decode('string-escape')
