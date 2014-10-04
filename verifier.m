IIIzFast = importdata('IIIz');
IxIxFast = importdata('IxIx');
xIIxFast = importdata('xIIx');

sz = [1 0 ; 0 -1];
sx = [0 1 ; 1 0];
IIIz = kron(kron(eye(20),eye(20)),kron(eye(2),sz));
IxIx = kron(kron(eye(20),sx),kron(eye(20),sx));
xIIx = kron(kron(sx,eye(20)),kron(eye(20),sx));

IIII = eye(1600);

IIIz = sparse(IIIz);
tic
for counter = 1:30
    P = IIII * IIIz;
end
toc

IxIx = sparse(IxIx);
tic
for counter = 1:30
    P = IIII * IxIx;
end
toc

xIIx = sparse(xIIx);
tic
for counter = 1:30
    P = IIII * xIIx;
end
toc

if isequal(IIIzFast,IIIz)
    disp 'Verified IIIz'
else
    disp 'Failed IIIz'
end

if isequal(IxIxFast,IxIx)
    disp 'Verified IxIx'
else
    disp 'Failed IxIx'
end

if isequal(xIIxFast,xIIx)
    disp 'Verified xIIx'
else
    disp 'Failed xIIx'
end
