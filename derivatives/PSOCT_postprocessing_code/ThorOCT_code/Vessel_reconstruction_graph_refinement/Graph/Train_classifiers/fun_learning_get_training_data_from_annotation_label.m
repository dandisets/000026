function data_str = fun_learning_get_training_data_from_annotation_label(label, feature, raw_data, remove_not_sureQ)
% fun_learning_get_training_data_from_annotation_label convert features and
% labels from annotation to training data structure. 
% Input: 
%   label: structure generated by annotation GUI. It has two fields: 
%       not_sureQ: logical vector, usually used for labeling the object that
%       should be removed, but the object is generated by sample
%       preparation, stitching, or any wired object that we dont't want to
%       use to confuse the classifier. 
%       to_removeQ: logical vector. True is the object is to be removed. 
%   feature: 2D table/ numerical array, each row is the feature vector for
%   each object
%   raw_data: (Optional), usually cell array or strucutre array, from which
%   the feature is derived from. 
% Output: 
%   data_str: structure with fields: 
%       normal, abonormal, not_sure, all: structure with fields: 
%           features
%           label
%           raw_data
%       
if nargin < 3
    raw_data = [];
    remove_not_sureQ = true;
elseif nargin < 4
    remove_not_sureQ = true;
end
data_str = struct; 
%% Training data template
% Had better write a class later
template_training_data = struct;
template_training_data.features = [];
template_training_data.label = [];
template_training_data.raw_data = [];

%% Interpretation of the label 
is_normal_Q = ~label.not_sureQ & ~label.artefactQ;
is_not_sureQ = label.not_sureQ;
is_artefact = label.artefactQ;
is_normal_remove_Q = label.to_removeQ;
% is_normal_kept_Q = ~label.not_sureQ & ~label.to_removeQ;    
if remove_not_sureQ
    is_remove_Q = label.not_sureQ | label.to_removeQ | label.artefactQ;
else
    is_remove_Q = label.to_removeQ | label.artefactQ;
end
%% Normal data
data_str.normal = template_training_data;
data_str.normal.features = feature(is_normal_Q, :);
data_str.normal.label = is_normal_remove_Q(is_normal_Q);
if ~isempty(raw_data)
    if isvector(raw_data)
        % Usually raw data is a cell array or structure array 
        data_str.normal.raw_data = raw_data(is_normal_Q);
    end
end
%% Artefact data
data_str.artefact = template_training_data;
data_str.artefact.features = feature(is_artefact, :);
data_str.artefact.label = is_artefact(is_artefact);
if ~isempty(raw_data)
    if isvector(raw_data)
        % Usually raw data is a cell array or structure array 
        data_str.artefact.raw_data = raw_data(is_artefact);
    end
end
%% Not sure
data_str.not_sure = template_training_data;
data_str.not_sure .features = feature(is_not_sureQ, :);
data_str.not_sure .label = is_not_sureQ(is_not_sureQ);
if ~isempty(raw_data)
    if isvector(raw_data)
        % Usually raw data is a cell array or structure array 
        data_str.not_sure.raw_data = raw_data(is_not_sureQ);
    end
end
%% All data
data_str.all = template_training_data;
data_str.all.features = feature;
data_str.all.label = label;
if ~isempty(raw_data)
    if isvector(raw_data)
        % Usually raw data is a cell array or structure array 
        data_str.all.raw_data = raw_data;
    end
end


end