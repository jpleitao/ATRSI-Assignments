load('/media/jpleitao/Data/PhD/PDCTI/ATRSI/ATRSI-Assignments/TP1/data/ARMAX_Input1.mat');

time = ARMAX_Input1(1, :);
ts = time(2) - time(1);
len = length(ARMAX_Input1(2,:));
estimation_size = floor(0.7 * len);
validation_size = len - estimation_size;
input_freq = 0.5;
number_periods_e = floor(time(estimation_size) / (1/input_freq));
number_periods_v = floor( (time(end) - time(estimation_size)) / ...
    (1/input_freq));

z_total = iddata(ARMAX_Output1(2,:)', ARMAX_Input1(2, :)', ts);
nk_est = delayest(z_total);

z_est = iddata(ARMAX_Output1(2, 1:estimation_size)', ARMAX_Input1(2, 1:estimation_size)', ts);
z_est.Period = number_periods_e;
z_est.Tstart = 0;

z_val = iddata(ARMAX_Output1(2, estimation_size+1:end)', ARMAX_Input1(2, estimation_size+1:end)', ts);
z_val.Period = number_periods_v;
z_val.Tstart = 0;

nk = 1:3;
na = 1:10;
nb = 1:10;
nc = 1:10;

max_fit = 0;
model_orders = [];

disp('Going for the loop!')

% Get best guess for parameters
for i=na
    for j=nb
        for l=nc
            for k=nk
                sys = armax(z_est, [i j l k]);
                
                Opt = compareOptions('InitialCondition', 'e');
                [y, val_fit, x0] = compare(z_val, sys, Opt);
                
                if val_fit > max_fit
                    max_fit = val_fit;
                    model_orders = [i j l k];
                end
            end
        end
    end
end

% Now, move on to recursive learning
estimator = recursiveARMAX(model_orders);
estimator.ForgettingFactor = 0.99;

% Arrays to store estimation results
np = size(estimator.InitialParameterCovariance, 1);
PHat = zeros(numel(z_est.InputData), np, np);
A = zeros(numel(z_est.InputData), numel(estimator.InitialA));
B = zeros(numel(z_est.InputData), numel(estimator.InitialB));
C = zeros(numel(z_est.InputData), numel(estimator.InitialC));
yHat = zeros(1, numel(estimator));

% Use the step command to update parameter values using one set of
% input-output data at each time step
for ct=1:estimation_size
    [ A(ct,:), B(ct,:), C(ct,:), yHat(ct) ] = step(estimator, z_est.OutputData(ct), z_est.InputData(ct));
    PHat(ct,:,:) = estimator.ParameterCovariance;
end

A = A(end, :);
B = B(end, :);
C = C(end, :);

true_output = z_est.OutputData';

% Plot errors
figure();
subplot(2,1,1);
plot(time(1:estimation_size), yHat, time(1:estimation_size), true_output);
legend('Estimated Output', 'Measured Output');
ylabel('System Output');
title('Estimated and Measured Outputs (Estimation)');
subplot(2,1,2);
plot(time(1:estimation_size), (yHat - true_output).^2);
ylabel('Quadratic Error (Estimation)');
xlabel('Time [s]');

mse_estimation = 1/estimation_size * sum( (yHat - true_output).^2)
mse_estimation_goodness = goodnessOfFit(yHat', z_est.OutputData, 'MSE')

fit_estimation = goodnessOfFit(yHat', z_est.OutputData, 'NRMSE')
% fit_estimation = % ; na GUI dava % +/-

% Simulate to validation data
estimator.EnableAdaptation = 0;

% A) Iterative error - Online -> MSE
true_output_val = z_val.OutputData';
A = zeros(validation_size, numel(estimator.InitialA)); % Not needed
B = zeros(validation_size, numel(estimator.InitialB)); % Not needed
C = zeros(numel(z_est.InputData), numel(estimator.InitialC)); % Not needed
yHat_val = zeros(1, validation_size);

get(estimator)

for ct=1:validation_size
    [ A(ct,:), B(ct,:), C(ct,:), yHat_val(ct) ] = step(estimator, z_val.OutputData(ct) , z_val.InputData(ct));
end

% Plot errors
figure();
subplot(2,1,1);
plot(time(estimation_size+1:end), yHat_val, time(estimation_size+1:end), true_output_val);
legend('Estimated Output', 'Measured Output');
ylabel('System Output');
title('Estimated and Measured Outputs (Validation)');
subplot(2,1,2);
plot(time(estimation_size+1:end), (yHat_val - true_output_val).^2);
ylabel('Quadratic Error (Validation)');
xlabel('Time [s]');

estimator.EnableAdaptation = 1;

mse_validation = 1/validation_size * sum( (yHat_val - true_output_val).^2)
mse_validation_goodness = goodnessOfFit(yHat_val', z_val.OutputData, 'MSE')
% Dao iguais, estamos a calcular bem

validation_fit_online = goodnessOfFit(yHat_val', z_val.OutputData, 'NRMSE')

% B) Offline - Fitness
sys = idpoly(estimator);
sys.Ts = ts;
Opt = compareOptions('InitialCondition', 'e');
[y, validation_fit_offline, x0] = compare(z_val, sys, Opt)   % Fit para a validaçao

% Save workspace to variable
save('armax_workspace.mat')
