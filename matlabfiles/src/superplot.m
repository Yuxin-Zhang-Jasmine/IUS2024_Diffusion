function superplot(varargin)


if nargin<3
	sc = 1.6;
else
	sc = varargin{3};
end	
if nargin <2
	x = varargin{1};
	[K,L] = size(x);
	t = 1:K;
else
	t = varargin{1};	
	x = varargin{2};
	[K,L] = size(x);	
end

xp = x./(ones(K,1)*(sc*max(x))) + ones(K,1)*(1:L);

plot(t,xp, Color="#77AC30");
ylim([1-1,L+1])
xlim([min(t),max(t)])
end
