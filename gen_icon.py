import struct, zlib, os
def png(w,h,px):
    def ck(t,d):
        c=t+d
        return struct.pack('>I',len(d))+c+struct.pack('>I',zlib.crc32(c)&0xffffffff)
    raw=b''
    for y in range(h):
        raw+=b'\x00'
        for x in range(w): raw+=struct.pack('BBBB',*px[y*w+x])
    return b'\x89PNG\r\n\x1a\n'+ck(b'IHDR',struct.pack('>IIBBBBB',w,h,8,6,0,0,0))+ck(b'IDAT',zlib.compress(raw))+ck(b'IEND',b'')

S,SS=256,3; H=S*SS; C=H//2
G=(13,148,136); W=(255,255,255)
def hit(px,py):
    x=(px-C)/(H*0.42); y=(py-C)/(H*0.42)
    # E bar (left)
    bw,bh,bg=0.30,0.08,0.05
    if -0.75<=x<=-0.45:
        if -0.55<=y<=-0.39: return True
        if -0.25<=y<=-0.09: return True
        if 0.05<=y<=0.21: return True
    # I bar (center)
    if -0.10<=x<=0.10 and -0.55<=y<=0.63: return True
    # L bar (right)
    if 0.25<=x<=0.55:
        if -0.55<=y<=0.35: return True
        if 0.40<=y<=0.55: return True
    return False

px=[(0,0,0,0)]*(S*S); fg=[(0,0,0,0)]*(S*S)
for sy in range(S):
    for sx in range(S):
        hc=0
        for dy in range(SS):
            for dx in range(SS):
                if hit(sx*SS+dx+0.5,sy*SS+dy+0.5): hc+=1
        N=SS*SS; a=min(255,int(round(hc*255/N)))
        if hc>0:
            r2=int(G[0]+(255-G[0])*(1-a/255)); g2=int(G[1]+(255-G[1])*(1-a/255)); b2=int(G[2]+(255-G[2])*(1-a/255))
            px[sy*S+sx]=(r2,g2,b2,255); fg[sy*S+sx]=(G[0],G[1],G[2],a)
        else: px[sy*S+sx]=(255,255,255,255)

bg_px=[(255,255,255,255)]*(S*S)
base=r'D:\github\Environmental-monitoring\AppScope\resources\base\media'
with open(os.path.join(base,'background.png'),'wb') as f: f.write(png(S,S,bg_px))
with open(os.path.join(base,'foreground.png'),'wb') as f: f.write(png(S,S,fg))
with open(os.path.join(base,'icon.png'),'wb') as f: f.write(png(S,S,px))
print('OK')
