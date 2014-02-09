
initialize_defaults;

print_text('Initializing VOT environment ...');

select_configuration = get_global_variable('select_configuration', 'configuration');

try
	environment_configuration = str2func(select_configuration);
    environment_configuration();
catch e
    if exist(select_configuration) ~= 2 %#ok<EXIST>
        print_text('Please copy configuration_template.m to %s.m in your workspace and edit it.', select_configuration);
        error('Setup file does not exist.');
    else
        error(e);
    end; 
end;

mkpath(get_global_variable('directory'));

experiment_stack = get_global_variable('experiment_stack', 'vot2013');

if exist(['stack_', experiment_stack]) ~= 2 %#ok<EXIST>
    error('Experiment stack %s not available.', experiment_stack);
end;

stack_configuration = str2func(['stack_', experiment_stack]);

experiments = {};

stack_configuration();

sequences_directory = fullfile(get_global_variable('directory'), 'sequences');
results_directory = fullfile(get_global_variable('directory'), 'results');

print_text('Loading sequences ...');

sequences = load_sequences(sequences_directory, get_global_variable('select_sequences', 'list.txt'));

if isempty(sequences)
	error('No sequences available. Stopping.');
end;

using_trackers = get_global_variable('trackers', {});

trackers = cell(length(using_trackers), 1);

print_text('Preparing trackers ...');

for t = 1:length(using_trackers)

    print_indent(1);
    
    print_text('Preparing tracker %s ...', using_trackers{t});

    trackers{t} = create_tracker(using_trackers{t}, ...
        fullfile(results_directory, using_trackers{t}));

    print_indent(-1);
    
end;

select_experiment = get_global_variable('select_experiment');

if ~isempty(select_experiment)
	selected_experiments = unique(select_experiment(select_experiment > 0 & ...
        select_experiment <= length(experiments)));
else
	selected_experiments = 1:length(experiments);
end;

clear t select_experiment using_trackers stack_configuration experiment_stack
clear sequences_directory results_directory environment_configuration