% Add libsvm stuff to path
addpath('code/libsvm');
addpath('code');

% Pre-Process dataset
castFilePath = 'data/SCOP40mini_sequence_minidatabase_19.cast';
fastaFilePath = 'data/SCOP40mini.fasta';

% preprocessDataset(fastaFilePath, castFilePath);
bestAUCS = trainClassifiers('data/');