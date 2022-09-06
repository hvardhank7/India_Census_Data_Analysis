create database india_census;
use india_census;
drop database india_census;

CREATE TABLE data1 (
	`District` VARCHAR(70) NOT NULL, 
	`State` VARCHAR(70) NOT NULL, 
	`Growth` DECIMAL(38, 2) NOT NULL, 
	`Sex_Ratio` DECIMAL(38, 0) NOT NULL, 
	`Literacy` DECIMAL(38, 2) NOT NULL
);

drop table data1;
desc data1;

LOAD DATA INFILE  
'E:/iNeuron/SQL/practice/New folder/Data1.csv'
into table data1
FIELDS TERMINATED by ','
ENCLOSED by '"'
lines terminated by '\r'
IGNORE 1 ROWS;

select count(*) from data1;


CREATE TABLE `Data2` (
	`District` VARCHAR(70) NOT NULL, 
	`State` VARCHAR(70) NOT NULL, 
	`Area_km2` int NOT NULL, 
	`Population` int NOT NULL
);

desc data2;
drop table data2;

LOAD DATA INFILE  
'E:/iNeuron/SQL/practice/New folder/Data2.csv'
into table data2
FIELDS TERMINATED by ','
ENCLOSED by '"'
lines terminated by '\n'
IGNORE 1 ROWS;

select * from data2;


-- number of rows into our dataset

select count(*) from data1;
select count(*) from data2;

-- dataset for jharkhand and bihar

select * from data1 where State in ('jharkhand','bihar');
desc data2;
desc data1;

-- population of India
select sum(Population) as Total_Population from data2;

-- avg growth of each state
select state, avg(Growth) as avg_growth from data1 group by state;

-- avg sex ratio
select state, round((Sex_Ratio),0) as avg_sex_ration
from data1 group by state 
order by avg_sex_ration desc;

-- avg literacy rate
select state, round((Literacy),0) as avg_literacy_ratio
from data1 group by state 
having avg_literacy_ration>90
order by avg_literacy_ratio desc;

-- top 3 state showing highest growth ratio
select State,avg(Growth) as Avg_Growth from data1 group by State
order by Avg_Growth desc limit 3;

-- bottom 3 state showing lowest sex ratio
select State,avg(Sex_Ratio) as Avg_Sex_Ratio from data1 group by State 
order by Avg_Sex_Ratio limit 3;


-- top and bottom 3 states in literacy state
select * from data1;

select State ,avg(Literacy) as Avg_Literacy from data1 
group by State order by Avg_Literacy;

select State ,avg(Literacy) as Avg_Literacy from data1 
group by State order by Avg_Literacy desc limit 3;

select State ,avg(Literacy) as Avg_Literacy from data1 
group by State order by Avg_Literacy limit 3;

-- union opertor
(select State ,avg(Literacy) as Avg_Literacy from data1 
group by State order by Avg_Literacy desc limit 3)
union
(select State ,avg(Literacy) as Avg_Literacy from data1 
group by State order by Avg_Literacy limit 3);


-- states starting with letter a
select distinct(District) from data1 where District LIKE 'T%';

-- joining both table
select * from data1 ;
select * from data2 ;

-- total males and females
select d.State,sum(d.males) as Total_Males, sum(d.females) as Totale_Females from
(select c.District,c.State,round(c.Population/c.Gen_Ratio+1,0) as males,
round((c.Population*c.Gen_Ratio)/(c.Gen_Ratio+1),0) as females from
(select d1.District,d1.State,d1.Sex_Ratio/1000 as Gen_Ratio,d2.Population 
from data1 d1
inner join data2 d2 
on d1.District=d2.District) as c) as d
group by d.State;

-- total literacy rate
select res2.State,sum(Literate_Population),sum(Illiterate_Population)from
(select res1.District,res1.State,round(res1.Literacy_Ratio*res1.Population,0) as Literate_Population,
round((1-res1.Literacy_Ratio)*res1.Population,0) as Illiterate_Population from
(select data1.District,data1.State,data1.Literacy/100 as Literacy_Ratio,data2.Population from data1
inner join data2
on data1.District=data2.District) as res1) res2
group by res2.State
order by res2.State;

-- population in previous census
select sum(f.Last_Census_Population) as Last_Census_Population,sum(f.Current_Census_Population) as Current_Census_Population from
(select e.State,sum(e.previous_census_pop) as Last_Census_Population,sum(e.Current_Population) as Current_Census_Population from
(select p.District,p.State,round(p.Population/(1+p.Growth),0) as previous_census_pop,p.Population as Current_Population from
(select data1.District,data1.State,data1.Growth/100 as Growth ,data2.Population from data1
inner join data2
on data1.District=data2.District) p) e
group by e.State)f;

-- window function top 3 districts from each state with highest literacy rate
select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from data1) a
where a.rnk in (1,2,3) order by state;

-- bottom 3 districts from each state with lowest literacy rate
select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy) last_rnk from data1) a
where a.last_rnk in (1,2,3) order by state
;
