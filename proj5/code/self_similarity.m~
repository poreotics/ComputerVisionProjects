function [ self_sim ] = self_similarity(channels, grid_dim )
%computes self similarity features for a given patch of channels
%self_sim is a list of length grid_dim^2 choose 2 
self_sim=[];
cell_size=size(channels,1)/grid_dim;

for p=1:size(channels,3),
    patch=channels(:,:,p);
    sums=sum(im2col(patch,[cell_size cell_size],'distinct'),1);
    assert(length(sums)==grid_dim^2);

    for i=1:length(sums)
        for j=i+1:length(sums)
            self_sim(end+1)=(sums(i)-sums(j));
        end
    end

end
assert(size(self_sim,2)==nchoosek(grid_dim^2,2)*size(channels,3));