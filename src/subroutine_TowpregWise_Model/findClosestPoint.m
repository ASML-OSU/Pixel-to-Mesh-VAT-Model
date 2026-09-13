function [closest_point, min_distance,idx] = findClosestPoint(curve_points, target_point)
% findClosestPoint - Finds the closest point on a curve to a target point
%
% Syntax:
%   [closest_point, min_distance] = findClosestPoint(curve_points, target_point)
%
% Inputs:
%   curve_points  - n-by-2 matrix of (x,y) points on the curve
%   target_point  - 1-by-2 vector [x0, y0] of the target point
%
% Outputs:
%   closest_point - 1-by-2 vector of the closest point on the curve
%   min_distance  - scalar, Euclidean distance to the closest point

    % Compute Euclidean distances
    deltas = curve_points - target_point;
    distances = sqrt(sum(deltas.^2, 2));

    % Find index of minimum distance
    [min_distance, idx] = min(distances);

    % Return closest point
    closest_point = curve_points(idx, :);
end
