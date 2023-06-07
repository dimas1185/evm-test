import os
import sys
from getpass import getpass
from binascii import hexlify
from ethereum.utils import privtoaddr, encode_hex, decode_hex, bytes_to_int
from ethereum import transactions
from binascii import unhexlify
import rlp
from rlp.sedes import big_endian_int
import json

EVM_SENDER_KEY  = os.getenv("EVM_SENDER_KEY", None)
# gives error when used by unsigned_tx.sign
# EVM_CHAINID     = os.getenv("EVM_CHAINID", 15555)

if len(sys.argv) < 6:
    print("{0} FROM TO AMOUNT INPUT_DATA NONCE [EVM_SENDER_KEY]".format(sys.argv[0]))
    sys.exit(1)

_from = sys.argv[1].lower()
if _from[:2] == '0x': _from = _from[2:]

_to     = sys.argv[2].lower()
if _to[:2] == '0x': _to = _to[2:]

_amount = int(sys.argv[3])
nonce = int(sys.argv[5])
if len(sys.argv) == 7:
    EVM_SENDER_KEY = sys.argv[6]

unsigned_tx = transactions.Transaction(
    nonce,
    1000000000,   #1 GWei
    1000000,      #1m Gas
    _to,
    _amount,
    unhexlify(sys.argv[4])
)

if not EVM_SENDER_KEY:
    EVM_SENDER_KEY = getpass('Enter private key for {0}:'.format(_from))

rlptx = rlp.encode(unsigned_tx.sign(EVM_SENDER_KEY), transactions.Transaction)

print("Eth signed raw transaction is {}".format(rlptx.hex()))