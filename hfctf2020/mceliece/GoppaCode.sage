class GoppaCode:
	def __init__(self, n, m, g):
		t = g.degree()
		F2 = GF(2);
		F_2m = g.base_ring(); 
		Z = F_2m.gen();
		PR_F_2m = g.parent(); 
		X = PR_F_2m.gen();
		codelocators = [];
		for i in range(2^m-1):
			codelocators.append(Z^(i+1));
		codelocators.append(F_2m(0));
		h = PR_F_2m(1);
		for a_i in codelocators:
			h = h*(X-a_i);
		gamma = [];
		for a_i in codelocators:
			gamma.append((h*((X-a_i).inverse_mod(g))).mod(g));
		H_check_poly = matrix(F_2m, t, n);
		for i in range(n):
			coeffs = list(gamma[i]);
			for j in range(t):
				if j < len(coeffs):
					H_check_poly[j,i] = coeffs[j];
				else:
					H_check_poly[j,i] = F_2m(0);
		H_Goppa = matrix(F2,m*H_check_poly.nrows(),H_check_poly.ncols());
		for i in range(H_check_poly.nrows()):
			for j in range(H_check_poly.ncols()):
				be = bin(H_check_poly[i,j].integer_representation())[2:];
				be = '0'*(m-len(be))+be; 
				be = list(be);
				H_Goppa[m*i:m*(i+1),j] = vector(map(int,be));
		G_Goppa = H_Goppa.right_kernel().basis_matrix();
		SyndromeCalculator = matrix(PR_F_2m, 1, len(codelocators));
		for i in range(len(codelocators)):
			SyndromeCalculator[0,i] = (X - codelocators[i]).inverse_mod(g);
		self._n = n;
		self._m = m;
		self._g = g;
		self._t = t;
		self._codelocators = codelocators;
		self._SyndromeCalculator = SyndromeCalculator;
		self._H_Goppa = H_Goppa;
		self._G_Goppa = G_Goppa;
	def Encode(self, message):
		return (message*self._G_Goppa);
	def _split(self,p):
		Phi = p.parent()
		p0 = Phi([sqrt(c) for c in p.list()[0::2]]);
		p1 = Phi([sqrt(c) for c in p.list()[1::2]]);
		return (p0,p1);
	def _g_inverse(self, p):
		(d,u,v) = xgcd(p,self.goppa_polynomial());
		return u.mod(self.goppa_polynomial());
	def _norm(self,a,b):
		X = self.goppa_polynomial().parent().gen();
		return 2^((a^2+X*b^2).degree());
	def _lattice_basis_reduce(self, s):
		g = self.goppa_polynomial();
		t = g.degree();
		a = []; a.append(0);
		b = []; b.append(0);
		(q,r) = g.quo_rem(s);
		(a[0],b[0]) = simplify((g - q*s, 0 - q))
		if self._norm(a[0],b[0]) > 2^t:
			a.append(0); b.append(0);
			(q,r) = s.quo_rem(a[0]);
			(a[1],b[1]) = (r, 1 - q*b[0]);
		else:
			return (a[0], b[0]);
		i = 1;
		while self._norm(a[i],b[i]) > 2^t:
			a.append(0); b.append(0);
			(q,r) = a[i-1].quo_rem(a[i]);
			(a[i+1],b[i+1]) = (r, b[i-1] - q*b[i]);
			i+=1;
		return (a[i],b[i]);

	def Decode(self, word_):
		g = self._g;
		word = copy(word_);
		X = g.parent().gen();
		synd = self._SyndromeCalculator*word.transpose();
		syndrome_poly = 0;
		for i in range (synd.nrows()):
			syndrome_poly += synd[i,0]*X^i
		(g0,g1) = self._split(g); sqrt_X = g0*self._g_inverse(g1);
		(T0,T1) = self._split(self._g_inverse(syndrome_poly) - X);
		R = (T0 + sqrt_X*T1).mod(g);
		(alpha, beta) = self._lattice_basis_reduce(R);
		sigma = (alpha*alpha) + (beta*beta)*X;
		for i in range(len(self._codelocators)):
			if sigma(self._codelocators[i]) == 0:
				word[0,i] += 1;
		return word;
	#Accessors
	def generator_matrix(self):
		return (self._G_Goppa);
	def goppa_polynomial(self):
		return (self._g);
	def parity_check_matrix(self):
		return (self._H_Goppa);
