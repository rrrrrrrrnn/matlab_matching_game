clear;
clc;
% 创建图形用户界面窗口，并设置其初始位置和大小
fig = uifigure('Name', '连连看小游戏made_by_ryr', 'Position', [0 0 300 300]);
% 在fig窗口中创建一个网格布局，列与列、行与行之间的间距为0，设置内边距为7单位 
grid = uigridlayout(fig, 'ColumnWidth', repmat({'1x'}, 1, 10), ...
    'RowHeight', repmat({'1x'}, 1, 10), ...
    'ColumnSpacing', 0, 'RowSpacing', 0, ...
    'Padding', [7 7 7 7]);

% 初始化变量x1, y1, x2, y2，它们将用于存储被点击的按钮的坐标
x1 = 0; y1 = 0; x2 = 0; y2 = 0;
% 定义全局变量m为一个12x12的矩阵，初始化为无穷大，用于存储按钮上的数字及状态
global m;
m = Inf(12,12);
for x = 1:10
    for y = 1:10
        button(x, y) = uibutton(grid, 'state', ...
            'Value', 0, ...
            'Text', num2str(randi([0 9])), ...
            'ValueChangedFcn', @(src, event) Fun(src, event, x, y, fig));
        m(x+1,y+1)=str2num(button(x,y).Text);
    end
end

% 将按钮数组存储到图形界面的 UserData 中
fig.UserData.buttons = button;
movegui(fig, 'center');


% 处理按钮点击事件
function Fun(src, event, x, y, fig)
    persistent prevButton;
    global x1; global y1; global x2; global y2; global m;
    disp(m);

    % 获取存储在图形界面 UserData 中的按钮数组
    button = fig.UserData.buttons;

    if isempty(prevButton)
        prevButton = button(x, y);
        x1 = x+1; y1 = y+1;
    else
        x2 = x+1; y2 = y+1;
        disp(['Button 1: (' num2str(x1-1) ', ' num2str(y1-1) ')']);
        disp(['Button 2: (' num2str(x2-1) ', ' num2str(y2-1) ')']);

        % 判断两个按钮是否可消除
        if ~strcmp(prevButton.Text, button(x, y).Text)
            button(x1-1, y1-1).Value = ~(button(x1-1, y1-1).Value);
            button(x2-1, y2-1).Value = ~(button(x2-1, y2-1).Value);
        elseif CanEliminate(x1, y1, x2, y2, m)
            % 执行消除操作
            % button(x1-1,y1-1).Enable=false;button(x2-1,y2-1).Enable=false;
            button(x1-1,y1-1).Visible='off';button(x2-1,y2-1).Visible='off';
            m(x1,y1)=inf;m(x2,y2)=inf;
        else
            button(x1-1, y1-1).Value = ~(button(x1-1, y1-1).Value);
            button(x2-1, y2-1).Value = ~(button(x2-1, y2-1).Value);
        end

        % 重置 prevButton
        prevButton = [];
    end
end

% 判断能否消除
function caneliminate = CanEliminate(x1, y1, x2, y2, m)
    caneliminate = false;
    %判断两点是否相邻
    if (x1==x2&&y1==y2)
        return
    elseif (x1==x2 && abs(y1-y2)==1) || (y1==y2 && abs(x1-x2)==1)
        caneliminate = 1;
    else
        caneliminate = IsPathClear(x1, y1, x2, y2, m);
    end
end

% 水平检查
function horizontalPathClear = IsHorizontalPathClear(x1, y1, x2, y2, m)
    horizontalPathClear = 1;
    % 如果x1与x2不同说明不在同一行，不水平
    if(x1~=x2)
        horizontalPathClear = 0;
        return;
    end

    % 如果相邻
    if abs(y1 - y2) == 1
        % 如果其中一个按钮的旁边有障碍物（即m矩阵中对应位置不是inf），则水平路径有障碍
        if m(x1, y2) ~= inf && m(x2, y1) ~= inf
            horizontalPathClear = 0;
            return;
        end
    end

    % 如果两个按钮不是相邻的，则检查它们之间的所有位置是否有障碍物
    step = sign(y2 - y1);
    currentY = y1 + step;
    while currentY ~= y2
        if m(x1, currentY) ~= inf
            horizontalPathClear = 0;
            return;
        end
        currentY = currentY + step;
    end
end

% 竖直检查
function verticalPathClear = IsVerticalPathClear(x1, y1, x2, y2, m)
    verticalPathClear = 1;
    % 如果y1与y2不同说明不在同一列，不竖直
    if(y1~=y2)
        verticalPathClear = 0;
        return;
    end

    % 如果相邻
    if abs(x1 - x2) == 1 
        % 如果其中一个按钮的旁边有障碍物（即m矩阵中对应位置不是inf），则竖直路径有障碍
        if m(x1, y2) ~= inf && m(x2, y1) ~= inf
            verticalPathClear = 0;
            return;
        end
    end
  
    % 如果两个按钮不是相邻的，则检查它们之间的所有位置是否有障碍物
    step = sign(x2 - x1);
    currentX = x1 + step;
    while currentX ~= x2
        if m(currentX, y1) ~= inf
            verticalPathClear = 0;
            return;
        end
        currentX = currentX + step;
    end
end


function pathClear = IsPathClear(x1, y1, x2, y2, m)
pathClear = 0;
    % 水平搜索
    for ya = 1:12
        % 如果其中一个按钮的旁边有障碍物（即m矩阵中对应位置不是inf），则水平路径有障碍
        if (IsHorizontalPathClear(x1, y1, x1, ya, m) && IsVerticalPathClear(x1, ya, x2, ya, m)&&IsHorizontalPathClear(x2, ya, x2, y2, m))
            pathClear = true;
            return;
        elseif IsHorizontalPathClear(x1, y1, x1, y2, m) && IsVerticalPathClear(x1, y2, x2, y2, m)             
            pathClear = true;               
            return;
        end
    end
   
    % 竖直搜索
    for xa = 1:12
        if (IsVerticalPathClear(x1, y1, xa, y1, m) && IsHorizontalPathClear(xa, y1, xa, y2, m)&&IsVerticalPathClear(xa, y2, x2, y2, m))
            pathClear = true;
            return; 
        elseif(IsVerticalPathClear(x1, y1, x2, y1, m) && IsHorizontalPathClear(x2, y1, x2, y2, m))
            pathClear = true;
            return;
        end
    end
end