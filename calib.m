clc
clear all
close all

%% Ajuste polinomial vel
% Velocidades objetivo
cd('2024-12-11')
name = '72124022.CL'; nV = 17; nD = 11; nP = 4;
c =1; % tanda de calibración direccional
k = [0.3 0.3];     % Condiciones iniciales   
        
[Vel_obj,vReal,E1_v,E2_v,p1,p2,Y,E1,E2,Velyaw] = readCL(name,nV,nD,nP,c);
% Y=90-Y;
p1 = fliplr(p1); p2 = fliplr(p2);
% Ajustamos polinomio de orden 4
p1_v = polyfit(E1_v, vReal/sqrt(2), 4)
p2_v = polyfit(E2_v, vReal/sqrt(2), 4)

%% Ajuste Ang
% Velocidad Objetivo

x = 1.2:0.01:2.07;
%x=[-10:0.1:30];

figure; hold on
    plot(x, polyval(p1_v, x), 'r')
    plot(x, polyval(p1, x), '.r')
    plot(x, polyval(p2_v, x), 'g')
    plot(x, polyval(p2, x), '.g')
    grid on
    xlabel('E [V]')
    ylabel('U [m/s]')
    title('Curvas de Calibración')
    legend('P1_{Matlab}', 'P1_{ThermalPro}','P2_{Matlab}', 'P2_{ThermalPro}', 'location', 'best')

figure; hold on
    plot(Y - 45, polyval(p1_v, E1), 'r', 'Marker', 'o')
    plot(Y - 45, flipud(polyval(p2_v, E2)), 'g', 'Marker', 'o')
    line([0 0], ylim, 'Color', [0 0 0], 'Linestyle', ':', 'linewidth', 2)
    grid on
    xlabel('Yaw [º]')
    ylabel('U [m/s]')
    title(['Calibración Angular: U = ' num2str(Velyaw), ' m/s'])
    
% Buscamos los valores k1 y k2 de mejor ajuste
options = optimset('Display','off','Algorithm','Levenberg-Marquardt');
[k_sol] = fsolve(@(x)myfun(x, E1, E2, p1, p2), k, options);
[k_sol_v] = fsolve(@(x)myfun(x, E1, E2, p1_v, p2_v), k, options)

% 
U1_v = sqrt((1+k_sol_v(2)^2)*flipud(polyval(p2_v, E2)).^2 - k_sol_v(2)^2*polyval(p1_v, E1).^2)/sqrt(2);
U2_v = sqrt((1+k_sol_v(1)^2)*polyval(p1_v, E1).^2 - k_sol_v(1)^2*flipud(polyval(p2_v, E2)).^2)/sqrt(2);

U1 = sqrt((1+k_sol(2)^2)*flipud(polyval(p2, E2)).^2 - k_sol(2)^2*polyval(p1, E1).^2)/sqrt(2);
U2 = sqrt((1+k_sol(1)^2)*polyval(p1, E1).^2 - k_sol(1)^2*flipud(polyval(p2, E2)).^2)/sqrt(2);


figure; hold on
plot(Y, polyval(p2_v, E2)./polyval(p2, E2),'g')
plot(Y, polyval(p1_v, E2)./polyval(p1, E2),'r')

% Resultados del ajuste
figure; hold on
plot(Y, atand((U1_v-U2_v)./(U1_v+U2_v)),'Marker','o', 'Color', [1 0 0])
plot(Y, atand((U1-U2)./(U1+U2)),'Marker','o', 'Color', [0 1 0])
xlabel('Yaw Calibración [º]')
ylabel('Ángulo Velocidad [º]')
title('Inclinación en Calibración Angular')
grid on

figure; hold on
plot(Y, sqrt((U1_v+U2_v).^2 + (U1_v-U2_v).^2),'r', 'Marker', 'o', 'Color', [1 0 0])
plot(Y, sqrt((U1+U2).^2 + (U1-U2).^2),'r', 'Marker', 'o', 'Color', [0 1 0])
line(xlim,[Velyaw, Velyaw], 'linestyle', ':', 'color', [0 0 1])
ylim([0 16])
xlabel('Yaw Calibración [º]')
ylabel('Vel. Calibración [m/s]')
title(['Velocidad en Calibración Angular (Vel_{obj.} = ', num2str(Velyaw), ' m/s)'])
grid on