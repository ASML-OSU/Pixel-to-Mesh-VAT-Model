% function cut_tapes(vec1,vec0)


% function intersectionPoints = findPolylineIntersections(line1, line2)
    function intersectionPoints = findPolylineIntersections(line1, line0)
    % line1 and line2: Nx2 and Mx2 arrays of [x, y] coordinates
    intersectionPoints = [];

    for i = 1:size(line1,1)-1
        A1 = line1(i, :);
        A2 = line1(i+1, :);

        for j = 1:size(line0,1)-1
            B1 = line0(j, :);
            B2 = line0(j+1, :);

            [isect, pt] = segmentIntersect(A1, A2, B1, B2);

            if isect
                intersectionPoints = [intersectionPoints; pt];
            end
        end
    end
end

function [intersect, P] = segmentIntersect(A1, A2, B1, B2)
    % Vectorized implementation of segment intersection
    P = [0, 0];
    intersect = false;

    da = A2 - A1;
    db = B2 - B1;
    dp = A1 - B1;

    dap = [-da(2), da(1)];
    denom = dap * db';
    if denom == 0
        return; % Parallel or colinear
    end

    num = dap * dp';
    P = (num / denom) * db + B1;

    % Check if P is within both segments
    if all(P >= min(A1, A2)) && all(P <= max(A1, A2)) && ...
       all(P >= min(B1, B2)) && all(P <= max(B1, B2))
        intersect = true;
    end
end
