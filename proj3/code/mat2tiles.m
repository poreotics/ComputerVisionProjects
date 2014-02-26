function outCell=mat2tiles(inArray,varargin)
%MAT2TILES - breaks up an array into a cell array of adjacent sub-arrays of
%            equal sizes
%
%   C=mat2tiles(X,D1,D2,D3,...,Dn)
%   C=mat2tiles(X,[D1,D2,D3,...,Dn])
%
%will produce a cell array C containing adjacent chunks of the array X,
%with each chunk of dimensions D1xD2xD3x...xDn. If a dimensions Di does
%not divide evenly into size(X,i), then the chunks at the upper boundary of
%X along dimension i will be truncated.
%
%It is permissible for the Di to be given value Inf. When this is done, it is
%equivalent to setting Di=size(X,i).
%
%If n < ndims(X), then the unspecified dimensions Dj, n<j<=ndims(X) will be
%set to size(X,i).
%
%If n > ndims(X), the the extra dimensions Dj, j>ndims(X) will  be ignored.



tileSizes=[varargin{:}];

N=length(tileSizes);

Nmax=ndims(inArray);

if N<Nmax
   
    tileSizes=[tileSizes,inf(1,Nmax-N)];
    
    
elseif N>Nmax    
    
    tileSizes=tileSizes(1:Nmax);
    
end
N=Nmax;

C=cell(1,N);

for ii=1:N %loop over the dimensions
    
 dim=size(inArray,ii);
 T=min(dim, tileSizes(ii));
 
 if T~=floor(T) || T<=0
     error 'Tile dimension must be a strictly positive integer or Inf'
 end
 
 nn=( dim / T );
   nnf=floor(nn);
 
 resid=[];
 if nnf~=nn 
    nn=nnf;
    resid=dim-T*nn;
 end
 
 C{ii}=[ones(1,nn)*T,resid];    
    
    
end

outCell=mat2cell(inArray,C{:});
