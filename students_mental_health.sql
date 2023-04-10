select * from Student_health.student_mental_health;
select count(*) from Student_health.student_mental_health; -- 100

-- DATA CLEANING
-- Standardize Date format:
select date_format(str_to_date(timestamp, '%d/%m/%Y %T'), '%Y-%m-%d') as date from Student_health.student_mental_health;

Alter table Student_health.student_mental_health
add Date_ date;

Update Student_health.student_mental_health
set Date_ = date_format(str_to_date(timestamp, '%d/%m/%Y %T'), '%Y-%m-%d'); 

select * from Student_health.student_mental_health;

-- Rename columns
ALTER TABLE Student_health.student_mental_health 
RENAME COLUMN  `Choose your gender` to Gender;

ALTER TABLE Student_health.student_mental_health 
RENAME COLUMN  `What is your course?` to Course,
RENAME COLUMN  `Your current year of Study` to Current_year_of_study,
RENAME COLUMN  `What is your CGPA?` to CGPA,
RENAME COLUMN  `Marital status` to Marital_Status,
RENAME COLUMN  `Do you have Depression?` to Depression,
RENAME COLUMN  `Do you have Anxiety?` to Anxiety,
RENAME COLUMN  `Do you have Panic attack?` to Panic_Attack,
RENAME COLUMN  `Did you seek any specialist for a treatment?` to Specialist_Treatment;

select * from Student_health.student_mental_health;

-- Lowcase in 'Current_year_of_study' column
select lower(Current_year_of_study) from Student_health.student_mental_health;

update Student_health.student_mental_health
set Current_year_of_study = lower(Current_year_of_study);

-- Drop Timestamp column:
ALTER TABLE Student_health.student_mental_health
DROP COLUMN Timestamp;

-- Add column ID:
ALTER TABLE Student_health.student_mental_health ADD ID int NOT NULL AUTO_INCREMENT primary key FIRST;
select * from Student_health.student_mental_health;

-- Add coulumns for Depression, Anxiety and Panic_attack if 'Yes' - 1, if 'No' - 0:
select *, case when Depression = 'Yes' then 1
else 0
end as depression_true,
case when Anxiety = 'Yes' then 1
else 0
end as anxiety_true,
case when Panic_Attack = 'Yes' then 1
else 0
end as panic_attack_true
from Student_health.student_mental_health;

Alter table Student_health.student_mental_health
add depression_true int;
update Student_health.student_mental_health
set depression_true = (case when Depression = 'Yes' then 1
else 0
end);
Alter table Student_health.student_mental_health
add anxiety_true int;
update Student_health.student_mental_health
set anxiety_true = (case when Anxiety = 'Yes' then 1
else 0
end);
Alter table Student_health.student_mental_health
add panic_attack_true int;
update Student_health.student_mental_health
set panic_attack_true = (case when Panic_Attack = 'Yes' then 1
else 0
end);
select * from Student_health.student_mental_health; 

Alter table Student_health.student_mental_health
add specialist_treatment_true int;
update Student_health.student_mental_health
set specialist_treatment_true = (case when Specialist_Treatment = 'Yes' then 1
else 0
end);
select * from Student_health.student_mental_health; 

-- ANALYSING
-- percentage of students have depression:
select Depression, count(Depression) as total_count_depression, 
count(Depression)*100/(select count(*) from Student_health.student_mental_health) as percentage 
from Student_health.student_mental_health
where Depression = 'Yes'
group by Depression;

-- percentage of students have Anxiety:
select Anxiety, count(Anxiety) as total_count_Anxiety, 
count(Anxiety)*100/(select count(*) from Student_health.student_mental_health) as percentage 
from Student_health.student_mental_health
where Anxiety = 'Yes'
group by Anxiety;

-- percentage of students have Panic_Attack:
select Panic_Attack, count(Panic_Attack) as total_count_Panic_Attack, 
count(Panic_Attack)*100/(select count(*) from Student_health.student_mental_health) as percentage 
from Student_health.student_mental_health
where Panic_Attack = 'Yes'
group by Panic_Attack;

-- Gender vs Depression/Anxiety/Panic_Attack:
select Gender, count(Gender) as total_count 
from Student_health.student_mental_health
where Depression = 'Yes' or Panic_Attack = 'Yes' or Anxiety = 'Yes'
group by Gender;

-- Percentage of female having Depression/Anxiety/Panic_Attack:
select Gender, count(Gender) as count_Female_with_mental_problem, 
(select count(Gender) from Student_health.student_mental_health where Gender = 'Female') as total_female,
count(Gender)*100/(select count(*) from Student_health.student_mental_health where Gender = 'Female') as percentage
from Student_health.student_mental_health
where Gender = 'Female' and (Depression = 'Yes' or Panic_Attack = 'Yes' or Anxiety = 'Yes')
group by Gender;

-- Percentage of male having Depression/Anxiety/Panic_Attack:
select Gender, count(Gender) as count_male_with_mental_problem, 
(select count(Gender) from Student_health.student_mental_health where Gender = 'Male') as total_male,
count(Gender)*100/(select count(*) from Student_health.student_mental_health where Gender = 'Male') as percentage
from Student_health.student_mental_health
where Gender = 'Male' and (Depression = 'Yes' or Panic_Attack = 'Yes' or Anxiety = 'Yes')
group by Gender;

-- Dinamics over time:
select Date_, count(*) as total_count_health_problem 
from Student_health.student_mental_health
where Depression = 'Yes' or Panic_Attack = 'Yes' or Anxiety = 'Yes'
group by Date_
order by Date_;

-- Percentage of mental health problems vs Current_year_of_study
-- Use CTE
with YearvsHealthProblem (Current_year_of_study, total_count_health_problem)
as
(select Current_year_of_study, count(*) as total_count_health_problem 
-- count(Panic_Attack)*100/(select count(*) from Student_health.student_mental_health) as percentage 
from Student_health.student_mental_health
where Depression = 'Yes' or Panic_Attack = 'Yes' or Anxiety = 'Yes'
group by Current_year_of_study
order by Current_year_of_study)

select t.Current_year_of_study, t.total_count_health_problem, t1.total_count,
t.total_count_health_problem*100/t1.total_count as percentage
from YearvsHealthProblem t
join
(select Current_year_of_study, count(*) as total_count  
from Student_health.student_mental_health
group by Current_year_of_study
order by Current_year_of_study) t1 on t.Current_year_of_study = t1.Current_year_of_study;

-- ID vs mental_health_problems:
select ID, sum(depression_true) as depression, sum(anxiety_true) as anxiety, sum(panic_attack_true) as panick_attack,
(depression_true + anxiety_true + panic_attack_true) as total
from Student_health.student_mental_health
group by ID having sum(depression_true) = 1 or sum(anxiety_true) = 1 or sum(panic_attack_true) = 1;

select *, (depression_true + anxiety_true + panic_attack_true) as total
from Student_health.student_mental_health
group by ID having total > 1;

-- with CTE
with ProbvsID (ID, depression, anxiety, panic_attack)
as
(select ID, sum(depression_true) as depression, sum(anxiety_true) as anxiety, sum(panic_attack_true) as panick_attack
from Student_health.student_mental_health
group by ID having sum(depression_true) = 1 or sum(anxiety_true) = 1 or sum(panic_attack_true) = 1)
select ID, depression, sum(depression) over(partition by depression) as total_depression,
anxiety, sum(anxiety) over(partition by anxiety) as total_anxiety, 
panic_attack, sum(panic_attack) over(partition by panic_attack) as total_panic_attack
from ProbvsID
order by ID;

-- Count students with mental health problem who has specialist treatment:

select count(ID) as having_treatment from Student_health.student_mental_health
where Specialist_Treatment = 'Yes'; -- 6

-- Percentage of students who has specialist treatment:
select count(ID) as having_treatment, (select count(ID) as having_problems
from Student_health.student_mental_health
where Depression = 'Yes' or Panic_Attack = 'Yes' or Anxiety = 'Yes') as having_problem,
count(ID)*100/(select count(ID) as having_problems from Student_health.student_mental_health
where Depression = 'Yes' or Panic_Attack = 'Yes' or Anxiety = 'Yes') as percentage from Student_health.student_mental_health
where Specialist_Treatment = 'Yes'; 

-- Percentage of students with mental problems having treatment vs gender
select p.Gender, p.having_treatment, t.having_problems, p.having_treatment*100/t.having_problems as percentage
from (select Gender, count(ID) as having_treatment
from Student_health.student_mental_health
where Specialist_Treatment = 'Yes'
group by Gender) p
join
(select Gender, count(ID) as having_problems from Student_health.student_mental_health
where Depression = 'Yes' or Panic_Attack = 'Yes' or Anxiety = 'Yes'
group by Gender) t on p.Gender = t.Gender; 

-- Mental Problems vs Course:
select Course, count(ID) as having_problems from Student_health.student_mental_health
where Depression = 'Yes' or Panic_Attack = 'Yes' or Anxiety = 'Yes'
group by Course
order by having_problems desc;

select Course, count(ID) as total_students from Student_health.student_mental_health
group by Course
order by total_students desc;
