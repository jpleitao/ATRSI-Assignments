load('/media/jpleitao/Data/PhD/PDCTI/ATRSI/ATRSI-Assignments/TP1/data/ARX_Input1.mat');

time = ARX_Input1(1, :);
ts = time(2) - time(1);
len = length(ARX_Input1(2,:));
estimation_size = floor(0.7 * len);
validation_size = len - estimation_size;
input_freq = 0.5;
number_periods_e = floor(time(estimation_size) / (1/input_freq));
number_periods_v = floor( (time(end) - time(estimation_size)) / ...
    (1/input_freq));

z_total = iddata(ARX_Output1(2,:)', ARX_Input1(2, :)', ts);

z_est = iddata(ARX_Output1(2, 1:estimation_size)', ARX_Input1(2, 1:estimation_size)', ts);
z_est.Period = number_periods_e;
z_est.Tstart = 0;

z_val = iddata(ARX_Output1(2, estimation_size+1:end)', ARX_Input1(2, estimation_size+1:end)', ts);
z_val.Period = number_periods_v;
z_val.Tstart = 0;

% Estimate model order (Even if i put na and nb = 1:100 it returns the
% same)
na = 1:10;
nb = 1:10;
nk = 1:10;
nk_est = delayest(z_total);  % nk_est=1
NN1 = struc(na, nb, nk);

param_e = selstruc(arxstruc(z_est(:,:,1), z_val(:,:,1), NN1));

% Create recursive estimator
estimator = recursiveARX(param_e);
estimator.ForgettingFactor = 0.99;

% Arrays to store estimation results
np = size(estimator.InitialParameterCovariance, 1);
PHat = zeros(numel(z_est.InputData), np, np);
A = zeros(numel(z_est.InputData), numel(estimator.InitialA));
B = zeros(numel(z_est.InputData), numel(estimator.InitialB));
yHat = zeros(1, numel(estimator));

% Use the step command to update parameter values using one set of
% input-output data at each time step
for ct=1:estimation_size
    [ A(ct,:), B(ct,:), yHat(ct) ] = step(estimator, z_est.OutputData(ct), z_est.InputData(ct));
    PHat(ct,:,:) = estimator.ParameterCovariance;
end

% COLOCAR NO RELATORIO!!!!
A = A(end,:);
B = B(end, :);

true_output = z_est.OutputData';

% Plot errors
figure();
subplot(2,1,1);
plot(time(1:estimation_size), yHat, time(1:estimation_size), true_output);
legend('Estimated Output', 'Measured Output');
ylabel('Estimated and Measured Outputs (Estimation)');
subplot(2,1,2);
plot(time(1:estimation_size), (yHat - true_output).^2);
ylabel('Quadratic Error (Estimation)');
xlabel('Time [s]');

mse_estimation = 1/estimation_size * sum( (yHat - true_output).^2)
mse_estimation_goodness = goodnessOfFit(yHat', z_est.OutputData, 'MSE')

fit_estimation = goodnessOfFit(yHat', z_est.OutputData, 'NRMSE')
% fit_estimation = 70% ; na GUI dava 77% +/-

% Simulate to validation data
estimator.EnableAdaptation = 0;

% A) Iterative error - Online -> MSE
true_output_val = z_val.OutputData';
A = zeros(validation_size, numel(estimator.InitialA)); % Not needed
B = zeros(validation_size, numel(estimator.InitialB)); % Not needed
yHat_val = zeros(1, validation_size);

get(estimator)

for ct=1:validation_size
    [ A(ct,:), B(ct,:), yHat_val(ct) ] = step(estimator, z_val.OutputData(ct) , z_val.InputData(ct));
end

% Plot errors
figure();
subplot(2,1,1);
plot(time(1:estimation_size), yHat, time(1:estimation_size), true_output);
legend('Estimated Output', 'Measured Output');
ylabel('Estimated and Measured Outputs (Validation)');
subplot(2,1,2);
plot(time(1:estimation_size), (yHat - true_output).^2);
ylabel('Quadratic Error (Validation)');
xlabel('Time [s]');
figure();


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
