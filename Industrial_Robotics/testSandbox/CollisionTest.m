% hold on
% R = UR3e;
% 
% q = [0,0,0,0,0,0,0];
% 
% tr = zeros(4,4,R.model.n+1);
% tr(:,:,1) = R.model.base.T;
% tr(:,:,2) = trotz(pi) * transl(0,0,q(1)) * transl(0,0,0) * trotx(pi/2);
% 
% L = R.model.links;
% for i = 2 : R.model.n
%     tr(:,:,i+1) = (tr(:,:,i) * trotz(q(i)) * transl(0,0,L(i).d) * transl(L(i).a,0,0) * trotx(L(i).alpha));
% end
% 
% 
% % matZ = axang2tform([0 0 1 pi/2]);
% % box = collisionBox(0.5,1,0.1);
% % box.Pose = matZ;
% % show (box)
% 
% 
% 
% for i = 1 : R.model.n
%     [X, Y, Z] = ellipsoid(tr(1:1,4:4,i),tr(2:2,4:4,i),tr(3:3,4:4,i),0.05,0.05,0.1);
%     mesh(X, Y, Z);
% end
%%   
tbl = PlaceObject('personMaleConstruction.ply',[-0.4,-0.3,0]);
vertex= get(tbl, 'Vertices');
faces = get(tbl, 'Faces');
faceNormals = get(tbl, 'Faces');
plotOptions.plotFaces = true;
% [vertex, faces, faceNormals] = Plane(0.5,0.5,0.4, -0.5,-0.5,0.4, 0.5,-0.5,0.41, -0.5,-0.5,0.41);

R = ur3e_modified(transl(0,0,0));
hold on
q = [0,0,0,0,0,0]; 

tr = zeros(4,4,R.model.n+1);

tr(:,:,1) = R.model.base.T;

%Creating transform of each joint link 
L = R.model.links;
for i = 1 : R.model.n
    tr(:,:,i+1) = (tr(:,:,i) * trotz(q(i)) * transl(0,0,L(i).d) * transl(L(i).a,0,0) * trotx(L(i).alpha));
end
%% Light Curtain
% Define the range for x and z coordinates
x = -0.5:0.05:0.5; % Change the range according to your requirement
z = 0:0.05:1; % Change the range according to your requirement

% Create a grid of coordinates for the plane
[X, Z] = meshgrid(x, z);

% Calculate the size of the grid
[m, n] = size(X);

% Create a matrix for y coordinates (all zeros for a plane in x-z)
Y = zeros(m, n);

% Initialize the curtain_points array to store the points
vertex = zeros(m * n, 3); % Initialize array to hold x, y, z coordinates

% Plotting the 3D plane of green dots and storing the points
index = 1;
for i = 1:m
    for j = 1:n
        % Plotting the points in the x-z plane
        plot3(X(i, j), Y(i, j), Z(i, j), 'go', 'MarkerSize', 5); % 'go' for green circles
        
        % Storing the points in the curtain_points array
        vertex(index, 1) = X(i, j); % x-coordinate
        vertex(index, 2) = Y(i, j); % y-coordinate (zero for x-z plane)
        vertex(index, 3) = Z(i, j); % z-coordinate
        index = index + 1;
    end
end
%%
% % Define initial and final positions
% initial_position = (transl(0.3, 0.3, 0.4) * trotx(0));
% final_position = (transl(0.3, -0.6, 0.4)* trotx(0));
% 
% % Animate the movement
% for step = 1:50
%     clf;
%     % Update the position gradually
%     PlaceObject('BinL.ply',[0.3,0.3-(step*0.01),0.4]);
%     pause(0.1);
% end

%% Collision and Motion
steps = 50;
Initial = R.model.fkine(R.model.getpos);
FinalWithNoRot = SE3([-0.3,-0.5,0]);
RotInitial= Initial.tr2rpy;
Final = FinalWithNoRot * SE3(trotx(RotInitial(1))* troty(RotInitial(2))* trotz(RotInitial(3)));

qI = R.model.ikcon(Initial);
qF = R.model.ikcon(Final);

%qMatrix of intial joints to the final joints based on the end effector
%postion
qTraj = jtraj(qI,qF,steps);
disp(qTraj)

%%
%based on the trasnform and the link of the robot that has been generated
%as well as the faces, vertex and facenormal of an object as ply flie 
%will check for collision and intesction indicating as follows and the
%number of detection
for k = 1:steps
    result(k) = IsCollision(R.model,qTraj(k,:),faces,vertex,faceNormals,false);
    R.model.animate(qTraj(k,:));
    drawnow();
end
display(['Total Intersection: ', num2str(sum(result))]);


%%
% function update_ellipsoid(R,q)
%     tr = zeros(4,4,R.model.n+1);
%     tr(:,:,1) = R.model.base.T;
% 
%     L = R.model.links;
%     for i = 1 : R.model.n
%         tr(:,:,i+1) = (tr(:,:,i) * trotz(q(i)) * transl(0,0,L(i).d) * transl(L(i).a,0,0) * trotx(L(i).alpha));
%     end
% 
%     for i = 1 : R.model.n
%         if i == 1
%             [X1, Y1, Z1] = ellipsoid(0, 0, 0.1, 0.06, 0.06, 0.125);
%             mesh(X1,Y1,Z1);
%         elseif i == 2
%             mid_point = (tr(1:3, 4, i+1) + tr(1:3, 4, i)) / 2;
%             [X2, Y2, Z2] = ellipsoid(mid_point(1), mid_point(2)-0.125, mid_point(3), 0.2, 0.06, 0.06);
%             mesh(X2,Y2,Z2);
%         elseif i == 3
%             mid_point = (tr(1:3, 4, i+1) + tr(1:3, 4, i)) / 2;
%             [X3, Y3, Z3] = ellipsoid(mid_point(1), mid_point(2)-0.03, mid_point(3), 0.125, 0.06, 0.06);
%             mesh(X3,Y3,Z3);
%         elseif i == 4
%             mid_point = (tr(1:3, 4, i+1) + tr(1:3, 4, i)) / 2;
%             [X4, Y4, Z4] = ellipsoid(mid_point(1), mid_point(2), mid_point(3), 0.06, 0.075, 0.06);
%             mesh(X4,Y4,Z4);
%         elseif i == 5
%             mid_point = (tr(1:3, 4, i+1) + tr(1:3, 4, i)) / 2;
%             [X5, Y5, Z5] = ellipsoid(mid_point(1), mid_point(2), mid_point(3), 0.06, 0.06, 0.1);
%             mesh(X5,Y5,Z5);
%         else
%             mid_point = (tr(1:3, 4, i+1) + tr(1:3, 4, i)) / 2;
%             [X6, Y6, Z6] = ellipsoid(mid_point(1), mid_point(2), mid_point(3), 0.06, 0.05, 0.06);
%             mesh(X6,Y6,Z6);
%         end
%     end
% end