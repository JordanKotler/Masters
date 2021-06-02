clc
clear
close all

%CURRENTLY SET UP TO RUN FOR 7kW charge point install

cycles = 261*3; %number of business days in a year * years
vehicles = 100;

store = zeros(vehicles,cycles);
distribution = zeros(vehicles,1);

DCcost= 500; %cost of one dockChain in £
CPcost = 7000; %cost of 7kW chargepoint installation in £
max_time = 8.5*60;

spaces = 100; %needs to be the same as number of cars generated in CBA
budget = 100000;


limit = ceil(budget/CPcost);

results = nan(1500,3); %preallocation for faster runtime
average = zeros(1500, 1);

sim_runs = 20;
    
for MC =1:sim_runs %632 seconds for 20 runs
    
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

    demand = time(store);

    
    for i=1:limit

        x_1 = i; %set no. of chargepoints for loop

        for j=0:(spaces/2) 

            x_2 = j; %set no. of dockChains for loop

            %calculate no. of spaces required
            if x_1 - x_2<=0 
                s = 2*x_2;
            else
                s = 2*x_2 + (x_1-x_2);
            end



%             if  (((x_1*CPcost)+(x_2*DCcost)) <= budget) && (s <= spaces)   %constraints for spaces and budget
%                   ( if statement not used due to mesh requirement on surface plot, surface constraints used instead)


                %calculating no. of dockChains per chargepoint

                quotient = fix(x_2/x_1);
                remainder = rem(x_2, x_1);
                
                CP =zeros(x_1);

                for w=1:(x_1)
                    CP(1, w) = quotient;
                end

                for p=1:remainder
                    CP(1,p) = CP(1,p) + 1;
                end

                config = zeros(size(demand,2),2);

                for d = 1:size(demand,2) %collect times for 783 days (261*3)
                    startpoint = 1;
                    temp =zeros(2,x_1);
                    today = demand(:,d); %moved out of allocation loop for efficiency

                    for cars=1:x_1
                        %decide on no. of spaces you can serve based on x_1 and x_2 allocation
                        if CP(1,cars)==0
                            CP(2, cars) = 1;
                        elseif CP(1,cars)>0
                            CP(2, cars) = (CP(1,cars))*2;
                        end


                        %go through and allocate a car demanding charge into a chargepoint queue
                        
                        index = CP(2,cars);
                        endpoint = startpoint + (index-1);
                        CP(3:(3+(index-1)), cars) = today(startpoint:endpoint);
                        startpoint = endpoint+1;

            %           sum the total charge from that queue
                        total = (sum(CP(:,cars)))-(sum(CP(1,cars)+CP(2,cars)));

                        if total > max_time
                           place_in_q = 3;
                           tot = 0;
                           while tot < max_time
                               tot = tot + CP(place_in_q, cars);
                               place_in_q = place_in_q + 1;
                           end

            %              tot - (CP(place_in_q-1,cars)) = fully charged minutes
                           temp(1,cars) = max_time;
                           temp(2,cars) = place_in_q-4;

                        elseif total < max_time
                            temp(1,cars) = total;
                            counter2 = 0;
                            for serv = 3:length(CP(:,cars))
                                if(CP(serv,cars))>0
                                    counter2 = counter2 + 1;
                                elseif (CP(serv,cars)) == 0
                                    break
                                end
                            end
                            temp(2,cars) = counter2;
                        end    
                    end

                    config(d,1) = sum(temp(1,:));
                    config(d,2) = sum(temp(2,:));


                end     



                p_ij = prof(x_1, x_2, sum(config(:,1)),sum(config(:,2)));

                results(((i-1)*spaces + j+1),1) = x_1;
                results(((i-1)*spaces + j+1),2) = x_2;
                results(((i-1)*spaces + j+1),3) = p_ij;

%             else
%                 
%                 results(((i-1)*spaces + j+1),1) = x_1;
%                 results(((i-1)*spaces + j+1),2) = x_2;
%                 results(((i-1)*spaces + j+1),3) = 'N';
%                        
%             end
        end
    end
    
    
    
    
    average = average + results(:,3);
    disp(MC)
end      

average = average/sim_runs;
% divide by 20


%% PLOTTING
%Surface plot generation


myX = 1:limit;
myY = 0:(spaces/2);
no_NAN = rmmissing(average);
no_NAN = no_NAN/1000;
zmatrix = reshape(no_NAN,length(myY),limit);
[X,Y] = meshgrid(myX, myY);
s1 = surf(X,Y,zmatrix);
xlabel('Charge points')
ylabel('dockChains')
zlabel('Profit (£ ''000)')
hold on

xPlane = [14.2857 10 10 14.2857];      % X coordinates of plane corners
% xPlane = [5 3.75 3.75 5];                % Constraint for 22kW chargepoint
yPlane = -14*xPlane + 200;      % Corresponding y coordinates for plane 1
% yPlane = -40*xPlane + 200; % Constraint for 22kw Chargepoint
zPlane = [-100 -100 150 150];  % Z coordinates of plane corners
budget_constraint = patch(xPlane, yPlane, zPlane, [0.6350 0.0780 0.1840], 'FaceAlpha', 0.3);  % Plot plane 1
hold on 

xPlane2 = [0 15 15 0];      % X coordinates of plane corners, ordered around the plane
yPlane2 = 0*xPlane + 50;      % Corresponding y coordinates for plane 2
space_constraint = patch(xPlane2, yPlane2, zPlane, [0.3010 0.7450 0.9330], 'FaceAlpha', 0.3);  % Plot plane 2


lgd = legend([budget_constraint, space_constraint], 'Budget constraint', 'Parking space constraint', 'AutoUpdate','off');
lgd.Location = 'best';

set(gcf, 'position',[10,10,900,600])

view([-40 6])


saveas(s1, 'MCplot7kW.png') %change name so you don't overwrite the wrong .jpg






%% Timing function
 function [period2charge] = time(dist)
 const = 2.5;
 chargerspeed = 7; %7kW charger %change to 22 for 22kW charger
 efficiency = 0.162; %average efficiency of top 3 EVs UK in kWh/km
 minutes = 60;
 period2charge = ceil(((const*dist*efficiency)/chargerspeed)*minutes);
 end

 %Profit calculation function
  function [profit] = prof(x_1,x_2,Q,satisfied)
 % costs
DCcost = 500; %cost of one dockChain in £
CPcost = 7000; %cost of 7kW chargepoint installation in £
MC = 0.04; % maintenance cost of 4%
yrs = 3;
E_B = (0.142/60); %buy price in £/kWmin
E_S = (0.4/60); %sale price in £/kWmin
fee_per_fullcharge = 2; %fee for service in £

revenue = Q*E_S*7 + fee_per_fullcharge*satisfied; %change from *7 to *22 for 22kW charger
var_cost = (Q*E_B*7);%change from *7 to *22 for 22kW charger
fix_cost = (x_1*CPcost) + (x_2*DCcost);

maintenance = MC*yrs*fix_cost;

profit =revenue - (fix_cost + var_cost + maintenance);
  end


