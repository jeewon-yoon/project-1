% for 
count = 1; 
for i = 1:10, 
    display(['i = ' num2str(i) ', count = ' num2str(count)]);
    count = count + 1;  
end 

% while
count = 1; 
i = 1; 
while i <= 10,  
    display(['i = ' num2str(i) ', count = ' num2str(count)]);
    count = count + 1;  
    i = i + 1; 
end 

% if 
for i = 1:10, 
    tmp = random('unid',10,1,1);
    if mod(tmp,2) == 1, 
        display(['Test ' num2str(i) ': ' num2str(tmp) ' is an odd number!']); 
    else
        display(['Test ' num2str(i) ': ' num2str(tmp) ' is an even number!']); 
    end
end 