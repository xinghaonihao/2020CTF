load("./GoppaCode.sage")
load("./McEliece.sage")

def init(m):
	n = 2**m;
	t = floor((2+(2**m-1)/m)/2);
	F_2m = GF(n,'Z');
	PR_F_2m = PolynomialRing(F_2m,'X');
	while 1:
		irr_poly = PR_F_2m.random_element(t);
		if irr_poly.is_irreducible():
			break;
	crypto = McElieceCryptosystem(n,m,irr_poly);
	return crypto,crypto.goppa_code().generator_matrix().nrows()

def encrypt(msg,crypto,l):
	bin = BinaryStrings()
	msg = map(int ,str(bin.encoding(msg)))
	msg+=[0 for i in range(l-(len(msg)%l))]
	assert(len(msg)%l == 0)
	cipher = []
	for i in range(len(msg)/l):
		plain = matrix(GF(2),1,l)
		for j in range(l):
			plain[0,j] = msg[i*l+j]
		encrypted = crypto.Encrypt(plain);
		cipher.append(encrypted)
	return cipher
crypto,l = init(6)
flag = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
cipher = encrypt(flag,crypto,l)
save(crypto.public_key(),"pubkey.sobj")
save(cipher,"cipher.sobj")

