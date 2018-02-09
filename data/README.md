### Codebook for XTMEM data

[1] `experiment_key.csv` - The experiments are presented in the paper in a different order than we conducted them. This file maps the original experiment numbers to the paper numbers, and described the experimental parameters of each experiment. It also includes experimental parameters for the set of previous studies by SPSS and XT. 

	* exp - original experiment number.
	* exp_recoded - experiment number in paper
	* one_3sub_label - identifies whether the single exemplar and 3-subordinate exemplar trial received the same label.
	* blocking - were the trials blocked by type or pseudo random?
	* order - in what order were the single exemplar and 3-subordinate exemplar trials presented?
	* timing - were training exemplars presented simultaneously (as in XT) or sequentially as in (SPSS)?
	* direct_replication_of - corresponding replication study
	* preregistered - was the study preregistered?

[2] `literature_ES.csv` - output of `get_literature_ES.R`. Calculated effect sizes for the 7 prior experiments in the literature.

	* exp_recoded - experiment number in paper
	* n - number of participants
	* d - cohens d
	* d_var - variance on d
	* high/low - 95% CI

[3] `anonymized/all_raw_A.csv` - output of `analysis/munge_anonymize_data.R`. It is the data from all 12 experiments in the rawest form. The only processing that has been done on this data is binding files from all the experiments together, adding an experiment id column, and anonymizing the subject ids. Each row corresponds to one participant.

	* ApprovalTime/AutoApprovalTime/AssignmentId/HITId/Assignment/AssignmentStatus - misc turk variables
	* AcceptTime/SubmitTime - actual time of acceptance and completetion of the task
	* exp - original experiment number	
	* subids - anonymized subject id
	* trainBlock_T* - block name (varied depending on whether the experiment was blocked or pseudo-random; * = trial num)
	* trainPics_T* - list of training exemplars for that trial (* = trial num)
	* condition_T* - condition name (* = trial num)
	* category_T* -  target category of that trial (vegetables, animals, vehicles; * = trial num)
	* word_T* - novel word used on that trial (* = trial num)
	* selected_T* - list of testing exemplars selected for that trial (* = trial num)
	* enjoyment/asses/comments - post-task questions (Did you enjoy the task?/Were you confused?)
	* gender/age/language/education/ - post-task demographic questions

[4] `anonymized/all_data_munged_A.csv` - output of `analysis/munge_anonymize_data.R`. This file contains all the data processed into long form so that each row corresponds to one trial. This is the file that is used in data analysis.

	* exp - original experiment number
	* subid - anonymized subject id
	* trial_num - trial number
	* category - target category (vegetables, animals, vehicles)
	* condition - condition name
	* n_unique_selected_cat - exemplars from how many categories were selected?
	* first_cat - what was the first category selected (3 = animals, 2 = vehicles, 1 = vegetables)
	* cat_num - numeric descriptor of category (3 = animals, 2 = vehicles, 1 = vegetables)
	* prop_sub - proportion subordinate pictures selected out of 2
	* prop_bas - proportion basic pictures selected out of 2
	* prop_sup - proportion superordinate pictures selected out of 4
	* only_responded_with_target_category - Were the selections only from the target category?

[5] `anonymized/no_dups_data_munged_A.csv` - output of `analysis/munge_anonymize_data_no_dups.R`. This is the same as all_data_munged_A.csv, except that duplicate participants have been removed.

