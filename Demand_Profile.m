clc
clear
close all

set(0, 'DefaultAxesFontSize', 15, 'DefaultAxesFontName', 'Times')


cycles = 261*3; %number of days
vehicles = 100;

store = zeros(vehicles,cycles);
distribution = zeros(vehicles,1);


for k = 1:cycles
    p1 = 0.1492; % 0 to 2km probability
    p2 = 0.3741; % 2 to 5km --
    p3 = 0.6647; % 5 to 10km --
    p4 = 0.9143; % 10 to 20km --
    p5 = 0.9628; % 20 to 30km --
    p6 = 0.9748; % 30 to 40km --
    p7 = 0.9837; % 40-60km --
    p8 = 1;      % 60km +   


    for i = 1:vehicles
        p = rand(1);
        if p <= p1
            distribution(i) = 2*rand(); % 0 to 2km
        elseif (p > p1) && (p <= p2)
            distribution(i) = 2+3*rand(); % 2 to 5km
        elseif (p > p2) && (p <= p3)
            distribution(i) = 5+5*rand(); % 5 to 10km
        elseif (p > p3) && (p <= p4)
            distribution(i) = 10+10*rand(); % 10 to 20km   
        elseif (p > p4) && (p <= p5)
            distribution(i) = 20+10*rand(); % 20 to 30km
        elseif (p > p5) && (p <= p6)
            distribution(i) = 30+10*rand(); % 30 to 40km
        elseif (p > p6) && (p <= p7)
            distribution(i) = 40+20*rand(); % 40 to 60km              
        elseif (p > p7) && (p <= p8)
            distribution(i) = 60+40*rand(); % 60km + (treated as 60-100km bin)
        end
        
    end
    
    store(:, k) = distribution; %saving each cycle to an array
    
end

duration = time(store);
totals = sum(duration);

% % assumptions
chargers = 9;
overnight = 8.5;
capacity = chargers*overnight*60;

avg = mean(totals)
min(totals)
bin_no = avg(1)/(overnight*60);



%% PLOTTING
upperlim = max(totals)+(max(totals)/10);
% lowerlim = min(totals)-(min(totals)/10);


xvals = linspace(1,cycles,cycles);
totals = totals';
figure
demandplot = scatter(xvals, totals, 'MarkerEdgeColor',[0 .5 .5], 'MarkerFaceColor',[0 .7 .7],'LineWidth',1.5);
hold on
[my, mx] = max(totals)
plot(mx, my,'o','MarkerSize',20, 'MarkerEdgeColor','b', 'LineWidth', 4);
midline = yline(avg,'--.r', 'LineWidth', 2.5);
% yline(capacity,'--. r', 'Capacity based on 9 7kW chargers operating for 8hr30mins')
xlabel("Days")
ylh = ylabel("Daily charging demand per 100 cars (mins)");
% title("Expected number of minutes demanded from " + vehicles + " vehicles over " + cycles + " days")
xlim([0 800])
ylim([0 upperlim])
legend([midline], 'Average', 'AutoUpdate','off')

%resizing plot
set(gcf, 'position',[10,10,1000,600])
grid on
box on
%saving plot
saveas(demandplot, '3yeardemand.png')
hold off

%% dataset saving

[longest, index] = maxk(totals, 5); %fifth 'longest' day

dataset = duration(:,index(5));

writematrix(dataset, 'dataset.csv');
writematrix(duration,'all_cycles.csv');


%% functions

 function [period2charge] = time(dist)
 const = 2.5;
 chargerspeed = 7; %7kW charger
 efficiency = 0.162; %average efficiency of top 3 EVs UK in kWh/km
 minutes = 60;
 period2charge = ceil(((const*dist*efficiency)/chargerspeed)*minutes);
 end

