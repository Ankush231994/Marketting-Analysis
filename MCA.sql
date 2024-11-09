use mca;
select * from campaigns;
select * from engagement;
select * from revenue;


###Task 6: Determine the conversion volume achieved by each marketing channel.
  ### Query the joined tables to summarize users converted by each channel.


select c.Channel, sum(e.Conversions) as Total_Conversion
from campaigns as c
join engagement as e 
on c.Campaign_ID = e.Campaign_ID
group by c.Channel
order by c.Channel desc;


##Task 7: Identify the top-performing campaigns(channels) based on return metrics.
## Calculate each campaign’s return by comparing spending to revenue.

select c.Campaign_ID,c.Budget,(r.New_User_Revenue + r.Returning_User_Revenue) AS Total_Revenue, 
		((r.New_User_Revenue + r.Returning_User_Revenue) / c.Budget) * 100 AS RoI
from revenue as r 
join campaigns as c 
on r.Campaign_ID = c.Campaign_ID 
order by RoI DESC
limit 5;

#Task 8: Map user engagement progression through stages.
 # - Track impressions to conversions, calculating rates at each engagement stage.
select Campaign_ID, Impressions,Clicks, Sign_Ups, Conversions
from engagement ;


##Task 9: Combine All Campaign Data.
 ## - Integrate data across campaigns, engagement, and revenue for a consolidated view.
select e.ID, e.Campaign_ID, e.Impressions, e.Clicks, e.Sign_Ups, e.Conversions,
	c.Channel, c.Start_Date, c.End_Date, c.Budget, c.Target_Audience, r.New_User_Revenue, 
	r.Returning_User_Revenue, (r.New_User_Revenue + r.Returning_User_Revenue) AS Total_Revenue 
from engagement as e 
join campaigns as c 
on e.Campaign_ID = c.Campaign_ID 
join revenue as r 
on e.Campaign_ID = r.Campaign_ID;

##Task 10: Highlight High-Return Campaigns.
  ##- Identify campaigns exceeding average returns with nested calculations.
WITH CampaignReturns AS 
( select r.Campaign_ID, (r.New_User_Revenue + r.Returning_User_Revenue) AS Total_Revenue, c.Budget, 
	((r.New_User_Revenue + r.Returning_User_Revenue) - c.Budget) / c.Budget AS RoI 
from revenue as r 
join campaigns c 
on r.Campaign_ID = c.Campaign_ID ), 

AverageRoI AS 
( select AVG(RoI) AS AvgRoI from CampaignReturns ) 
select cr.Campaign_ID, cr.Total_Revenue, cr.Budget, cr.RoI 
from CampaignReturns cr 
join AverageRoI ar on cr.RoI > ar.AvgRoI;


##Task 11: Calculate Cumulative Revenue Trends by Channel.
##  - Display cumulative revenue by channel ordered by campaign start date.

select c.Channel, c.Start_Date, SUM(r.New_User_Revenue + r.Returning_User_Revenue) 
		OVER (PARTITION BY c.Channel order by c.Start_Date) AS Cumulative_Revenue
from campaigns as c 
join revenue as r 
on c.Campaign_ID = r.Campaign_ID 
order by c.Channel, c.Start_Date;