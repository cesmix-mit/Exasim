function createnodes(p::Array{Float64,2},t::Array{Int,2},porder::Int)
# %CREATEDGNODES Computes the Coordinates of the DG nodes.
# %   DGNODES=CREATENODES(MESH,FD,FPARAMS)
# %
# %      MESH:      Mesh Data Structure
# %      FD:        Distance Function d(x,y)
# %      FPARAMS:   Additional parameters passed to FD
# %      DGNODES:   Triangle indices (NPL,2,NT). The nodes on
# %                 the curved boundaries are projected to the
# %                 true boundary using the distance function FD
# %

# % npv : number of nodes per volume element
# % nfv : number of faces per volume element
# % npf : number of nodes per face element

nve,ne = size(t);
nd=size(p,1);

elemtype = 0;
if (nd==2) && (nve==4)
    elemtype=1;
end
if (nd==3) && (nve==8)
    elemtype=1;
end

plocal,~,~,~,perm = masternodes(porder,nd,elemtype);
npl = size(plocal,1);

philocal = zeros(Float64, npl, nve);

if nd==1
    xi  = plocal[:,1];
    philocal[:,1] = 1.0 .- xi;
    philocal[:,2] = xi;
elseif nd==2 && nve==3 # tri
    xi  = plocal[:,1];
    eta = plocal[:,2];
    philocal[:,1] = 1.0 .- xi .- eta;
    philocal[:,2] = xi;
    philocal[:,3] = eta;
elseif nd==2 && nve==4 # quad
    xi  = plocal[:,1];
    eta = plocal[:,2];
    philocal[:,1] = (1.0 .- xi).*(1.0 .- eta);
    philocal[:,2] = xi.*(1.0 .- eta);
    philocal[:,3] = xi.*eta;
    philocal[:,4] = (1.0 .- xi).*eta;
elseif nd==3 && npv==4 # tet
    xi   = plocal[:,1];
    eta  = plocal[:,2];
    zeta = plocal[:,3];
    philocal[:,1] = 1.0 - xi - eta - zeta;
    philocal[:,2] = xi;
    philocal[:,3] = eta;
    philocal[:,4] = zeta;
elseif nd==3 && npv==8 # hex
    xi   = plocal[:,1];
    eta  = plocal[:,2];
    zeta = plocal[:,3];
    philocal[:,1] = (1.0 .-xi).*(1.0 .-eta).*(1.0 .-zeta);
    philocal[:,2] = xi.*(1.0 .-eta).*(1.0 .-zeta);
    philocal[:,3] = xi.*eta.*(1.0 .-zeta);
    philocal[:,4] = (1.0 .-xi).*eta.*(1.0 .-zeta);
    philocal[:,5] = (1.0 .-xi).*(1.0 .-eta).*(zeta);
    philocal[:,6] = xi.*(1.0 .-eta).*(zeta);
    philocal[:,7] = xi.*eta.*(zeta);
    philocal[:,8] = (1.0 .-xi).*eta.*(zeta);
end

# Allocate nodes
dgnodes = zeros(Float64,npl,ne,nd);
for dim=1:nd
  for node=1:nve
    dp = reshape(philocal[:,node],npl,1)*reshape(p[dim,t[node,:]],1,ne);
    dgnodes[:,:,dim] = dgnodes[:,:,dim] + reshape(dp,npl,ne);
  end
end

dgnodes = permutedims(dgnodes,[1, 3, 2]);

return dgnodes, elemtype, perm

end
