import os,random,sys,string
from hashlib import sha256,sha512
import SocketServer
from Crypto.Util.number import *
from secret import flag
class Task(SocketServer.BaseRequestHandler):
    def proof_of_work(self):
        random.seed(os.urandom(8))
        proof = ''.join([random.choice(string.ascii_letters+string.digits) for _ in xrange(20)])
        digest = sha256(proof).hexdigest()
        self.request.send("sha256(XXXX+%s) == %s\n" % (proof[4:],digest))
        self.request.send('Give me XXXX:')
        x = self.request.recv(10)
        x = x.strip()
        if len(x) != 4 or sha256(x+proof[4:]).hexdigest() != digest: 
            return False
        return True

    def dorecv(self):
        try:
            res = int(self.request.recv(512))
        except Exception as e:
            print e
            res = 0
        return res

    def dosend(self, msg):
        try:
            self.request.sendall(msg)
        except:
            pass

    def handle(self):
        if not self.proof_of_work():
            self.request.close()
        a = random.randint(10,50)
        b = random.randint(1,2)
        try:
            self.dosend("Please send me 150 (x,y) each of which statisfies x ** 2 - a * y ** 2 = b\n")
            self.dosend("Where a = "+str(a)+", b = "+str(b)+"\n")
            sols = []
            cheat = 0
            for i in range(150):
                x = self.dorecv()
                y = self.dorecv()
                if x <=0 or y<=0:
                    cheat = 1 
                    self.dosend("You want to cheat me?\n")
                    break
                if(x**2-a*y**2!=b):
                    cheat = 1 
                    self.dosend("You want to cheat me?\n")
                    break
                sol = (x,y)
                if sol in sols:
                    cheat = 1 
                    self.dosend("You want to cheat me?\n")
                    break
                else:
                    sols.append(sol)
            if cheat == 0:
                self.dosend("flag is:"+flag+"\n")
        except :
            self.dosend("Something error!\n")

        self.request.close()
        


class ThreadedServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
    pass


if __name__ == "__main__":
    HOST, PORT = '0.0.0.0', 11111
    server = ThreadedServer((HOST, PORT), Task)
    server.allow_reuse_address = True
    server.serve_forever()

