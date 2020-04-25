from Crypto.Util.number import *
from flag import FLAG,false_flag
import gmpy2
import random
import hashlib
import base64

def rsaEncode(msg):
    f=open("out","a")
    while True:
        ran=random.randint(3, 12)
        if isPrime(ran):
            break
    e=ran*getPrime(30)
    p = getPrime(1024)
    q = getPrime(1024)
    while (not gmpy2.gcd((p-1)*(q-1),e)==ran or p*q<pow(msg,ran)):
        p = getPrime(1024)
        q = getPrime(1024)
    n=p*q
    assert(pow(msg,ran)<n)
    print("rsaEncode_init_finish!")
    dsaEncode(p)
    f.write("rsaEncode n:"+hex(n)+"\n")
    f.write("rsaEncode e:"+hex(e)+"\n")
    c=pow(msg,e,n)
    f.write("rsaEncode flag is:"+hex(c)+"\n")
    f.close()

def rsaEncode2(m):
    m=int.from_bytes(m.encode(),'big')
    f=open("out","w")
    while True:
        ran=random.randint(20, 50)
        if isPrime(ran):
            break
    e=ran*getPrime(30)
    p = getPrime(1024)
    q = gmpy2.next_prime(p)
    while (not gmpy2.gcd((p-1)*(q-1),e)==ran or p*q>pow(m,ran)):
        p = getPrime(1024)
        q = gmpy2.next_prime(p)
    n=p*q
    assert(pow(m,ran)>n)
    c=pow(m,e,n)
    f.write("n2:"+hex(n)+"\n")
    f.write("e2:"+hex(e)+"\n")
    f.write("rsaEncode2 re is:"+hex(c)+"\n")
    f.close()
    print("rsaEncode2_finish!")
    return pow(m,ran,n)

def dsaEncode(p):
    key=genkey(p)
    (r,s,k,q)=sign(rsaEncode2(false_flag),key)
    sig= r.to_bytes(205, 'big') + s.to_bytes(205, 'big') + k.to_bytes(205, 'big')+ q.to_bytes(205, 'big')
    f=open("out","a")
    f.write("dsaEncode :"+base64.b64encode(sig).decode()+"\n")
    f.close()

def genkey(x):
    # DSA
    N=1024
    L=2048-N-1
    while True:
        q = getPrime(N)
        if q-1>x:
            break
    assert(q-1>x)
    while True:
        t = random.getrandbits(L)
        p = (t * 2*q + 1)
        if isPrime(p):
            break
    e = (p-1) // q
    g = pow(2, e, p)
    y = pow(g, x, p)
    print("genkey_finish!")
    return {'y':y, 'g':g, 'p':p, 'q':q, 'x':x}

def sign(m, key):
    g, p, q, x = key['g'], key['p'], key['q'], key['x']
    k = random.randint(1, q-1)
    Hm = int.from_bytes(hashlib.md5(str(m).encode('utf-8')).hexdigest().encode(), 'big')
    r = pow(g, k, p) % q
    s = (inverse(k, q) * (Hm + x*r)) % q
    return (r, s, k, q)

if __name__ == "__main__":
    msg=int.from_bytes(FLAG.encode(),'big')
    rsaEncode(msg)


