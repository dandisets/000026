function loop_str = fun_graph_get_bilink_loops(input_graph)
% fun_graph_get_bilink_loops finds the loops that consists of two link
% segments. 
% Input: 
%   input_graph: structure generated by fun_skeleton_to_graph
% Output: 
%   loop_str: structure with fields
%       link_label_pair: N-by-2 numerical array for N pair of links label
%       link_pair_num_voxels: N-by-2 numerical array for the length of N pair of links
%       loop_num_voxel: N-by-1 numerical vector, number of voxels in the
%       loop
% Written by Xiang Ji on Jan 28, 2019

% Find the links that have no endpoints and are not self-loop
loop_str = fun_initialized_structure_array_with_fieldname_list({'link_label_pair', ...
    'link_pair_num_voxels', 'loop_num_voxel', 'connected_node_labe', ...
    'link_label_pair_ge_3', 'link_num_voxels_ge_3', 'loop_num_voxel_ge_3', ...
    'connected_node_label_ge_3'});
no_endpointQ = all(input_graph.link.connected_node_label > 0, 2);
is_not_self_loopQ = input_graph.link.connected_node_label(:,1) ~= input_graph.link.connected_node_label(:,2);
to_diff_nodesQ = no_endpointQ & is_not_self_loopQ;
to_diff_nodes_idx = find(to_diff_nodesQ);
to_diff_nodes_node_label = input_graph.link.connected_node_label(to_diff_nodesQ, :);
% Find duplicated node pairs
ordered_node_label = sort(to_diff_nodes_node_label, 2, 'ascend');
[~, ~, unique_label_ind] = unique(ordered_node_label, 'row', 'stable');
[paired_ind, ~] = fun_bin_data_to_idx_list(unique_label_ind);
num_pair = cellfun(@numel, paired_ind);
% assert(all(num_pair < 3), 'Exist more then 2 links connected to the same two nodes');
paired_ind_2 = paired_ind(num_pair == 2);
if ~isempty(paired_ind_2)
    if isrow(paired_ind_2{1})
        paired_ind_2 = cat(1, paired_ind_2{:});
    else
        paired_ind_2 = cat(2, paired_ind_2{:})';
    end
    assert(size(paired_ind_2, 2) == 2, 'Number of columns should be 2');
    loop_str.link_label_pair = to_diff_nodes_idx(paired_ind_2);
    loop_str.link_pair_num_voxels = input_graph.link.num_voxel_per_cc(loop_str.link_label_pair);
    loop_str.loop_num_voxel = sum(loop_str.link_pair_num_voxels, 2);
    loop_str.connected_node_label = input_graph.link.connected_node_label(loop_str.link_label_pair(:,1), :);
end

% More than 2 links connected to same pair of nodes: 
paired_ind_ge_3 = paired_ind(num_pair > 2);
num_pair_ge_3 = numel(paired_ind_ge_3);
if ~isempty(num_pair_ge_3)
    loop_str.link_label_pair_ge_3 = cell(num_pair_ge_3, 1);
    loop_str.link_num_voxels_ge_3 = cell(num_pair_ge_3, 1);
    loop_str.loop_num_voxel_ge_3 = zeros(num_pair_ge_3, 1);
    loop_str.connected_node_label_ge_3 = zeros(2, num_pair_ge_3);
    for iter_pair = 1 : num_pair_ge_3
        loop_str.link_label_pair_ge_3{iter_pair} = to_diff_nodes_idx(paired_ind_ge_3{iter_pair});
        loop_str.link_num_voxels_ge_3{iter_pair} = input_graph.link.num_voxel_per_cc(loop_str.link_label_pair_ge_3{iter_pair});
        loop_str.loop_num_voxel_ge_3(iter_pair) = sum(loop_str.link_num_voxels_ge_3{iter_pair});
        loop_str.connected_node_label_ge_3(:, iter_pair) = input_graph.link.connected_node_label(loop_str.link_label_pair_ge_3{iter_pair}(1), :);
    end
    loop_str.connected_node_label_ge_3 = loop_str.connected_node_label_ge_3';
end
end