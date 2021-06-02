clc;
clear
close all;

set(0, 'DefaultAxesFontSize', 15, 'DefaultAxesFontName', 'Times')


import = readtable('all_cycles.csv');
demand = table2array(import);

%% Parameters (can be adjusted accordingly)


DCcost= 500; %cost of one dockChain in £
CPcost = 7000; %cost of 7kW chargepoint installation in £
time = 8.5*60;

spaces = 100; %needs to be the same as number of cars generated in CBA


%Budget section
minBudget = 10000;
maxBudget = 100000;
increment = 1000;

spend = zeros((maxBudget-minBudget)/increment,4);
up = 1; 

%% Loops

for budget=minBudget:increment:maxBudget %BUDGET VAR COMMENT
    
    limit = ceil(budget/CPcost);

    results = nan(1500,3); %preallocation for faster runtime

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



              if  (((x_1*CPcost)+(x_2*DCcost)) <= budget) && (s <= spaces)   %constraints for spaces and budget


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

                for d = 1:size(demand,2) %collect times for 1305 days (261*5)
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
    %                         total = sum(CP(3:length(CP(:,cars)),cars));
                        total = (sum(CP(:,cars)))-(sum(CP(1,cars)+CP(2,cars)));

                        if total > time
                           place_in_q = 3;
                           tot = 0;
                           while tot < time
                               tot = tot + CP(place_in_q, cars);
                               place_in_q = place_in_q + 1;
                           end

            %              tot - (CP(place_in_q-1,cars)) = fully charged minutes
                           temp(1,cars) = time;
                           temp(2,cars) = place_in_q-4;

                        elseif total < time
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
    % 
                else
                    
                    results(((i-1)*spaces + j+1),1) = x_1;
                    results(((i-1)*spaces + j+1),2) = x_2;
                    results(((i-1)*spaces + j+1),3) = 'N';
    %                 

            end
        end
    end
    
    
 % BUDGET VAR COMMENT
    [highest, location] = max(results(:,3));
    spend(up,1) = budget;
    spend(up,2) = highest;
    spend(up,3) = results(location,1);
    spend(up,4) = results(location,2);
    
    up = up + 1
 end %BUDGET VAR COMMENT       



%% PLOTTING

profvsbudget = plot(spend(:,1)/1000, spend(:,2)/1000, 'k-o', 'MarkerFaceColor','#0000FF','MarkerSize',5,'MarkerEdgeColor','none');
xlabel('Budget (£ ''000)')
ylabel('Maximum profit (£ ''000)')
xlim([0 maxBudget/1000]) 
% title('Maximum profit generated from varying budgets')
grid on
saveas(profvsbudget, 'profit-vs-budget.jpg')




ratio = spend(:,4)./spend(:,3);
figure
ratiovsbudget = plot(spend(:,1)/1000,ratio, 'k-o', 'MarkerFaceColor','#0000FF','MarkerSize',5,'MarkerEdgeColor','none');

xlabel('Budget (£ ''000)');
ylabel('dockChains per charge point');
% title('Ratio of dockChains to chargepoints at the maximum points of profit for differing budgets')
xlim([0 maxBudget/1000]) 
ylim([4 11])

grid on



saveas(ratiovsbudget, 'ratio-vs-budget.jpg')






%% PROFIT FUNCTION
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
