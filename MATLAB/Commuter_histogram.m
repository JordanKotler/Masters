clc
clear
close all

set(0, 'DefaultAxesFontSize', 15, 'DefaultAxesFontName', 'Times')

%unequal bins
freq1 = [477503 719503 930073 798590 155052 38418 28398 52288];

x1 = categorical({'0-2', '2-5', '5-10', '10-20', '20-30', '30-40', '40-60', '60-100'});
x1 = reordercats(x1,{'0-2', '2-5', '5-10', '10-20', '20-30', '30-40', '40-60', '60-100'});



%more equal bins
freq2 = [2127079 798590 155052 38418 80686];

x2 = categorical({'0 - 10', '10 - 20','20 - 30','30 - 40', '40-100'});
x2 = reordercats(x2, {'0 - 10', '10 - 20','20 - 30','30 - 40', '40-100'});



%% plotting histogram with unequal widths FINAL PLOT TO BE USED

xlab ='Bins widths (km)';
ylab = 'Frequency density';


figure
edges = [0 2 5 10 20 30 40 60 100];

h = histogram('BinEdges',edges,'BinCounts',freq1);
h.Normalization = 'countdensity';
xticks([0 2 5 10 20 30 40 60 100])

%appearance
h.FaceColor = '#77AC30';
h.LineWidth =  1;
h.FaceAlpha = 1;

% title('Histogram of commuter trips to work in London')
xlabel (xlab);
ylabel (ylab);

grid off
box off

saveas(h, 'Histogram of Distribution.png');

