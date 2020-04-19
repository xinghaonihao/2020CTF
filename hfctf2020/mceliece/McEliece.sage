
class McElieceCryptosystem:
	def __init__(self, n, m, g):
		goppa_code = GoppaCode(n,m,g);
		k = goppa_code.generator_matrix().nrows();
		S = matrix(GF(2),k,[random()<0.5 for _ in range(k^2)]);
		while (rank(S) < k) :
			S[floor(k*random()),floor(k*random())] +=1;
		rng = range(n); P = matrix(GF(2),n);
		for i in range(n):
			p = floor(len(rng)*random());
			P[i,rng[p]] = 1; rng=rng[:p]+rng[p+1:];
		self._m_GoppaCode = goppa_code;
		self._g = g;
		self._t = g.degree();
		self._S = S;
		self._P = P;
		self._PublicKey = S*(self._m_GoppaCode.generator_matrix())*P;
	def _GetRowVectorWeight(self,n):
		weight = 0;
		for i in range(n.ncols()):
			if n[0,i] == 1:
				weight = weight+1;
		return weight;
	def Encrypt(self, message):
		assert (message.ncols() == self.public_key().nrows());
		err_vec = matrix(1,self.goppa_code().generator_matrix().ncols());
		while (self._GetRowVectorWeight(err_vec) < self.max_num_errors()):
			err_vec[0, randint(1,self.goppa_code().generator_matrix().ncols()-1)] = 1;
		code_word = message*self.public_key();
		return copy(code_word + err_vec);
	def Decrypt(self, received_word):
		assert (received_word.ncols() == self.public_key().ncols());
		message = received_word * ~(self._P);
		message = self.goppa_code().Decode(message);
		message = (self._S*self.goppa_code().generator_matrix()).solve_left(message);
		return copy(message);
	#Accessors
	def public_key(self):
		return copy(self._PublicKey);
	def goppa_code(self):
		return copy(self._m_GoppaCode);
	def max_num_errors(self):
		return copy(self._t);
