function angle_deg = tangentAngleAtPoint(line, pt)
    minDist = inf;
    tangent = [0, 0];

    for i = 1:size(line,1)-1
        a = line(i,:);
        b = line(i+1,:);
        d = pointToSegmentDistance(pt, a, b);

        if d < minDist
            minDist = d;
            tangent = b - a;
        end
    end

    angle_rad = atan2(tangent(2), tangent(1));
    angle_deg = rad2deg(angle_rad);

    % Ensure angle is in [0, 360)
    if angle_deg < 0
        angle_deg = angle_deg + 360;
    end
end
function d = pointToSegmentDistance(P, A, B)
    AP = P - A;
    AB = B - A;
    t = max(0, min(1, dot(AP, AB) / dot(AB, AB)));
    proj = A + t * AB;
    d = norm(P - proj);
end
