

USE HEALTHCARE;

SELECT *
FROM patient_s

SELECT COUNT(*)
FROM patient_s;

USE HEALTHCARE;

select count(*)
from doctors;


/* Patient management.§ Retrieve complete patient profiles.*/

select *
from patient_s;

/* List patients with missing contact information (to ensure data quality).*/

SELECT  patient_id,name,contact,age
from patient_s
where patient_id IS  null  
OR name is    null
OR contact is  null
OR age is null;

/* identify the  duplicate records*/

select insurance_id,count(*) as count
from patient_s
group by insurance_id
having count(*)>1;

select name ,count(*) as count
from patient_s
group by name
having count(*)>1;

select contact,count(*) as count
from patient_s
group by contact
having count(*)>1;

/*
SELECT 
    Patient_ID,
    CONCAT(name, ' ', surname) AS FullName,
    Gender,
    contact,
   age,
    Address,
    Insurance_ID
FROM Patients;
*/
select address,count(*) as count
from patient_s
group by address
having count(*)>1;



exec sp_help patient_s;
/*
*********************************************************************
*********************************************************************/

	/*B. Doctor Management
	• 
		○  Analysis: 
			§ Query for doctors by specialization.
			§ Retrieve a doctor’s appointment history.*/

			/*Query for doctor by specialization*/

			SELECT *
			FROM doctors;

SELECT *
from doctors
where specialization='Cardiology';

/*retrives doctors appintment history*/

SELECT d.doctor_id,d.name,d.specialization,
a.appointment_id,a.patient_id,a.appointment_date,a.status
FROM doctors AS d
INNER JOIN appointments AS a
ON d.doctor_id=a.doctor_id
order by appointment_date;

		/*Appointment Scheduling & Management
			• Booking & Tracking: 
				○ Requirements: 
					§ Record appointment details (Appointment_ID, Patient_ID, Doctor_ID, Appointment_Date, Status, optional notes).
					§ Ensure proper status tracking (Scheduled, Completed, Cancelled).
				○  Analysis: 
					§ List upcoming appointments with patient and doctor details.
					§ Count appointments by status to identify cancellation or no-show trends.*/
/*LIST UPCOMING  APPOINTMENTS WITH patient and DOCTOR DETAILS:*/

SELECT  a.appointment_id,a.appointment_date,a.status,
p.patient_id,p.name,p.age,p.insurance_id,p.contact,

d.doctor_id,d.name,d.specialization,d.contact_info
from appointments as a
inner join patient_s as  p
on a.patient_id=p.patient_id
inner join doctors as d
on a.doctor_id=d.doctor_id
where a.status='pending' and appointment_date between '1/7/2024' and '7/1/2024'

order by a.appointment_date asc;

/*Count appointments by status to identify cancellation or no-show trends.*/

SELECT appointment_date,status,count(*) as total_canceled
from appointments
where status='canceled'
group by appointment_date,status
order by appointment_date


/*Medical Records Management
			• Record Keeping: 
				○ Requirements: 
					§ Store medical records (Record_ID, Patient_ID, Doctor_ID, Diagnosis, Treatment, Record_Date).
					§ Maintain a history of treatments and diagnoses per patient.
				
				Analysis Queries: 
					§ Retrieve complete medical histories for a given patient.
					§ Analyze diagnosis frequency or treatment types across the patient base.*/

/*Retrieve complete medical histories for a given patient*/

select m.record_id,m.patient_id,m.diagnosis,m.prescription,m.record_date,
p.name,p.age,p.contact,p.insurance_id
from medical_records as m
inner join patient_s as p
on m.patient_id=p.patient_id
where m.patient_id=7537
order by m.record_date ASC;

/* Analyze diagnosis frequency or treatment types across the patient base.*/
/* analyse diagnosis frequency*/

select diagnosis,count(*) as count_frequ
from medical_records
group by diagnosis
order by count_frequ DESC

/*treatment types across the patient*/
/*************/



SELECT m.diagnosis, d.specialization, COUNT(*) AS treatment_count,  
       AVG(m.treatment_cost) AS avg_treatment_cost  
FROM medical_records AS m  
INNER JOIN doctors AS d ON m.doctor_id = d.doctor_id  
GROUP BY m.diagnosis, d.specialization  
ORDER BY avg_treatment_cost DESC;

/* Billing & Payment Management
			• Invoice & Payment Processing: 
				○ Requirements: 
					§ Record billing details (Billing_ID, Patient_ID, Appointment_ID, Amount, Payment_Status, Payment_Date).
					§ Track payments to flag outstanding balances.
				○ Analysis : 
					§ Calculate total revenue (sum of paid bills).
					§ List billing records with pending payments.*/

				/*	calculate total revenue(sum of paid bills) */



				select *
				from billing
		
select  sum(total_amount) as sum_paidbills
from billing
where payment_status='Paid'
		
		/*§ List billing records with pending payments.*/

	select *
	from billing
	where payment_status='pending'
	
	

	/*Data Integrity & Security
		• Integrity & Access: 
			○ Requirements: 
				§ Enforce referential integrity through primary/foreign key constraints.
				§ Validate data types and use check constraints (e.g., valid phone numbers).
			○ Technical Analysis Queries: 
				§ Identify records with missing or anomalous data.
				§ Audit changes in data (if triggers or logs are implemented).*/
/*Identify records with missing or anomalous data.*/


/*1.linking appointments to the patients  and doctors */		

ALTER TABLE appointments
add constraint fk_appointpatients
foreign key (patient_id) references patient_s(patient_id);

ALTER TABLE appointments
add  constraint fk_appointdoctors
foreign key(doctor_id) references doctors(doctor_id);

/*2linking medical records with patint and doctors*/

ALTER TABLE medical_records
add constraint fk_medpatient
foreign key (patient_id) references patient_s(patient_id);

ALTER TABLE medical_records
add constraint fk_meddoctors
foreign key (doctor_id) references doctors(doctor_id);

/*3linking billing with patient and appointment  */

ALTER TABLE billing
add constraint fk_billpatient
foreign key (patient_id) references patient_s(patient_id);



/*Identify records with missing or anomalous data.*/

/* I dentify missing data values*/

select *
from appointments
WHERE patient_id IS NULL OR doctor_id IS NULL OR appointment_date IS NULL;

select *
from patient_s
where name is null or contact is null or age is null;

/*select *
from  billing
where patient_id is null or total_amount is null  or payment_status is null
or payment_date is null;*/

select *
from doctors
where name is null or contact_info is null;

select *
from medical_records
where patient_id is null or doctor_id is null or treatment_cost is null
or record_date is null;

/* identify anolumes data inavlid values */

/*check total amount which is less than or equal to zero*/
select *
from billing
where total_amount<= 0;

/*check for invalid appointment dates* (future or old dates)*/

select *
from appointments
where appointment_date < = '1/1/2000';

/*find invalid patient ages */

select *
from patient_s
where age<=0 or age>=120;

/* check incorrect payemnt status */
select distinct payment_status
from billing;

/*using trigger to trach changes*/


CREATE VIEW V1 
as 
select doctor_id
from doctors;

select *
from v1 ;

				/*Analytical Reporting & Decision Support
					• Reporting & Dashboards: 
						○ Requirements: 
							§ Create views, stored procedures, or reports that consolidate key information from multiple tables.
							§ Enable real-time dashboards for KPIs and operational metrics.
						○  Analysis: 
							§ Generate trend reports (e.g., monthly appointments, revenue trends).
							§ Aggregate metrics for performance reviews.*/


/*Generate trend reports (e.g., monthly appointments, revenue trends).*/

select *
from appointments;


create view monthly_appointment 
as
select format(appointment_date, 'YYY-MM') as month,
count (appointment_id) as toatal_appointments
from appointments
group by format(appointment_date, 'YYY-MM')

select *
from monthly_appointment;

/* view calculated total renevue per month */

CREATE VIEW Monthly_Revenue AS  
SELECT  
    FORMAT(payment_date, 'yyyy-MM') AS month,  
    SUM(total_amount) AS total_revenue  
FROM Billing  
WHERE payment_date IS NOT NULL  
GROUP BY FORMAT(payment_date, 'yyyy-MM');

select *
from Monthly_Revenue;

select format(total_revenue/1000000,'n2') + 'M' as revenue_m
from Monthly_Revenue

/*view for yearly revenue trends*/

create view yearly_revenue
as
select format( payment_date,'YYY') as year,
	   sum(total_amount) as total_year

	from billing
	where payment_date is not null
	group by format( payment_date,'YYY');

	select *
	from yearly_revenue;

	select  round(total_year/1000000,2) as total,year
	from yearly_revenue

	/* Aggregate metrics for performance reviews.*/

	/*doctor performance summary review*/

	CREATE VIEW Doctor_Performance AS  
SELECT  
    d.doctor_id,  
    d.specialization,  
    COUNT(a.appointment_id) AS total_appointments,  
    COUNT(DISTINCT m.patient_id) AS total_patients,  
    AVG(m.treatment_cost) AS avg_treatment_cost,  
    SUM(b.total_amount) AS total_revenue  
FROM doctors AS d  
LEFT JOIN appointments AS a ON d.doctor_id = a.doctor_id  
LEFT JOIN medical_records AS m ON d.doctor_id = m.doctor_id  
LEFT JOIN billing AS b ON m.record_id = b.billing_id  
GROUP BY d.doctor_id, d.specialization;

/*		Key Performance Indicators (KPIs)
		A. Appointment Efficiency */
		/*Average wait time(booking to appointment) */




		select *
		from appointments;


		select *
		from medical_records;

	/*
	select m.patient_id, m.record_date,a.appointment_date,a.status,count(m.patient_id) as patient_count
		from appointments as a
		inner join medical_records as m
		on a.patient_id=m.patient_id
		group by a.status,m.record_date,a.appointment_date,m.patient_id */


		SELECT  
    AVG(DATEDIFF(day, Record_Date, Appointment_Date)) AS Avg_Wait_Time  
FROM medical_records as m
inner join appointments as a
on m.patient_id=a.patient_id
WHERE Record_Date IS NOT NULL AND Appointment_Date IS NOT NULL;

SELECT * 
FROM Appointments  as a
join medical_records as m
on a.patient_id=m.patient_id
WHERE Record_Date > Appointment_Date;
		
		
SELECT  AVG(ABS(DATEDIFF(day, Record_Date, Appointment_Date))) AS Avg_Wait_Time  
FROM medical_records as m
inner join appointments as a
on m.patient_id=a.patient_id
WHERE Record_Date IS NOT NULL AND Appointment_Date IS NOT NULL;

		
		/* to findincorrecy records*/
		SELECT a.Appointment_ID, m.Record_Date, a.Appointment_Date,  
       DATEDIFF(day, m.Record_Date, a.Appointment_Date) AS Wait_Days  
FROM Appointments as a
inner join medical_records as m
on a.patient_id=m.patient_id
WHERE m.Record_Date > a.Appointment_Date OR DATEDIFF(day, m.Record_Date, a.Appointment_Date) > 365;

/* 		Only fetch correct records with appointmnet and record date which is not graeter than 365 and appointment is schduled after the record date.
	*/

	SELECT a.Appointment_ID, m.Record_Date, a.Appointment_Date,  
       DATEDIFF(day, m.Record_Date, a.Appointment_Date) AS Wait_Days  
FROM Appointments as a
inner join medical_records as m
on a.patient_id=m.patient_id
WHERE m.Record_Date < a.Appointment_Date and DATEDIFF(day, m.Record_Date, a.Appointment_Date) < 365;
	
		
		/* for fixing incorrect dates */

update m
set m.record_date = DATEADD(day,-30,a.appointment_date)
from medical_records as m
join appointments as a
on m.patient_id=a.patient_id
where m.record_date > a.appointment_date or datediff(day,m.record_date,a.appointment_date)>365;


select *
from medical_records;

/*
SELECT m.record_date, a.appointment_date, DATEDIFF(day, m.record_date, a.appointment_date) AS Wait_Days  
FROM medical_records AS m  
JOIN appointments AS a  
ON m.patient_id = a.patient_id  
WHERE m.record_date > a.appointment_date  
   OR DATEDIFF(day, m.record_date, a.appointment_date) > 365; */

   /* use check constraint for future*/

   select 
   count(case when status ='canceled' then 1 end) * 100.0 /count(*) as canellation_rate
   from appointments;

   /* FINANCIAL PERFORMANCE: total revenue*/
   /*total amount collected from billing records where payment is paid*/

   select round(sum(total_amount),4) as toatlbilling_amount
    from billing
	where payment_status ='paid';

	select sum(total_amount) as totalbilling_amount
	from billing
	where payment_status='paid';

	/* 		• Payment Collection Efficiency: 
			○ Definition: Ratio of payments received versus total billed.
		• Average Billing Turnaround Time: 
			○ Definition: Time between appointment completion and payment receipt. */

			/* payment collection efficiency*/

		select m.treatment_cost,b.total_amount, sum(b.total_amount/m.treatment_cost) as paycolle_efficiency
		from billing as b
		inner join medical_records as m
		on b.patient_id= m.patient_id
/*************************************************/

/*
	SELECT  
    FORMAT((SUM(CASE WHEN payment_status = 'Paid' THEN total_amount ELSE 0 END) * 100.0 / SUM(total_amount)), 'N2')  
    AS Payment_Received_Percentage  
FROM billing;
		
SELECT  
    FORMAT((SUM(CASE WHEN b.payment_status = 'Paid' THEN b.total_amount ELSE 0 END) * 100.0 / SUM(m.treatment_cost)), 'N2')  
    AS Payment_Received_Percentage  
FROM billing AS b  
JOIN medical_records AS m
ON b.patient_id = m.patient_id;  -- Adjust join condition based on your schema

SELECT  
    FORMAT(
        (SUM(CASE WHEN payment_status = 'Paid' THEN total_amount ELSE 0 END) * 100.0) / 
        (SELECT SUM(treatment_cost) FROM medical_records), 
    'N2') AS Payment_Received_Percentage  
FROM billing ;
*/
SELECT  
   FORMAT((SUM(b.total_amount) * 100.0 / SUM(m.treatment_cost)), 'N2') AS Payment_Collection_Efficiency  
FROM billing AS b  
JOIN medical_records AS m  
ON b.patient_id = m.patient_id;

/*  			• Average Billing Turnaround Time: 
				○ Definition: Time between appointment completion and payment receipt.
*/

select AVG(datediff(day,a.appointment_date,b.payment_date) )as average_billing
from appointments as a
join billing as b
on a.patient_id=b.patient_id
where a.appointment_date is not  null and
b.payment_date is not null
and b.payment_status='paid'
and b.payment_date >a.appointment_date
and datediff(day,a.appointment_date,b.payment_date)<365;

select b. payment_date, a.appointment_date
from billing as b
join appointments as a
on b.patient_id=a.patient_id
where b.payment_status='paid'
order by b.payment_date,a.appointment_date asc
;

/*	C. Doctor Performance
		• Appointments per Doctor: 
			○ Definition: Average number of appointments handled per doctor.
		• Doctor Utilization Rate: 
Definition: Percentage of a doctor's available hours that are scheduled.*/
/*average appointments handled per doctor*/

select count(a.appointment_id) as toatalapooi,d.doctor_id,d.name,d.specialization,(COUNT(a.appointment_id) * 1.0 / (SELECT COUNT(DISTINCT doctor_id) FROM appointments WHERE status = 'completed') )  
    AS avg_appointments_per_doctor 
from appointments as a
inner join doctors as d
on a.doctor_id=d.doctor_id
where a.status='completed'
group by d.name,d.specialization,d.doctor_id
order by d.doctor_id asc



		(COUNT(a.appointment_id) * 1.0 / (SELECT COUNT(DISTINCT doctor_id) FROM appointments WHERE status = 'completed'))  
    AS avg_appointments_per_doctor
	
	SELECT  
    d.doctor_id,  
    d.name AS doctor_name,  
    d.specialization,  
    COUNT(a.appointment_id) AS total_appointments,  
    (COUNT(a.appointment_id) * 1.0 / (SELECT COUNT(DISTINCT doctor_id) FROM appointments WHERE status = 'completed'))  
    AS avg_appointments_per_doctor  
FROM appointments AS a  
INNER JOIN doctors AS d  
ON a.doctor_id = d.doctor_id  
WHERE a.status = 'completed'  
GROUP BY d.doctor_id, d.name, d.specialization  
ORDER BY d.doctor_id ASC;

/*	D. Patient Engagement
		• Patient Retention Rate: 
			○ Definition: Percentage of patients returning for multiple appointments.
		• New Patient Growth: 
			○ Definition: Number of new patient registrations over a period.*/
/* percentage of patients returning for multiple appointments */

select *
from appointments;

select avg(count(patient_id)*dignosis)

SELECT 
    FORMAT((COUNT(DISTINCT CASE WHEN appointment_count > 1 THEN patient_id END) * 100.0 
            / COUNT(DISTINCT patient_id)), 'N2') AS Returning_Patient_Percentage
FROM (
    SELECT patient_id, COUNT(appointment_id) AS appointment_count
    FROM appointments
    GROUP BY patient_id
) AS subquery

/* 					• New Patient Growth: 
					Number of new patient registrations over a period. */
/*now  i am considering new date period between 8/4/2022 to 10/4/2022, registration nothin but record date.*/

select *
from medical_records;



SELECT COUNT(DISTINCT patient_id) AS new_registrations, record_date
FROM medical_records a
WHERE record_date BETWEEN '2022-04-08' AND '2022-09-10'
GROUP BY record_date
ORDER BY record_date;

/*	E. Operational Efficiency
		• Data Completeness: 
			○ Definition: Percentage of records that have all required fields completed.
		• System Performance Metrics: 
			○ Definition: Query response times, system uptime, etc. */
	/*Percentage of records that have all required fields completed.*/
	
	
	select 
	(count (case when patient_id is not null and
	doctor_id is not null and
	diagnosis is not null and
	treatment_cost is not null and
	record_date is not null then
	 1 end)* 100 /count(*))  as percentage_completerecords
	from medical_records ;


	/*	• System Performance Metrics: 
		○ Definition: Query response times, system uptime, etc.*/

		/* query response time */

		SET STATISTICS TIME ON;  
SELECT * FROM Appointments WHERE status = 'Completed';  
SET STATISTICS TIME OFF;


	select *
	from medical_records;

	/*	3. Mapping Technical Analysis Query Questions to Business Requirements & KPIs
	Below are sample technical questions you might ask—and corresponding SQL query examples—that align with your business requirements and KPIs:
	Patient Management */
 /* How many patients have incomplete contact information? */

select insurance_id, count(*) as duplicte_ids
from patient_s
group by insurance_id
having count(*)>1

select *
from patient_s;

select 
count(case when  patient_id is  null and
name is  null and gender is  null and contact is  null and age is  null
and address is  null and insurance_id is  null then 1 end) as incomplete_info
from patient_s;

/* Retrieve full profile and appointment details for a specific patient.Query Example*/select  p.name,p.gender,p.contact,p.age,p.address, p.insurance_id,a.appointment_date,a.doctor_id,a.appointment_date,a.statusfrom patient_s as pjoin appointments  as aon p.patient_id=a.patient_idwhere p.patient_id=8;/*	Doctor Management
Question: Which doctors specialize in a given field?Query Example:*/select doctor_id,name,experience_years,contact_infofrom doctorswhere specialization='Neurology';select *from appointments;/* What is the appointment history for a particular doctor?*/select d.name,d.doctor_id,d.contact_info, a.appointment_id,a.patient_id,a.appointment_date,a.statusfrom doctors as dinner join appointments as aon d.doctor_id=a.doctor_idwhere d.name='David Davis';/* 	Appointment Scheduling & Management
Question: What are the upcoming appointments?Query Example:*/SELECT a.Appointment_ID, a.Appointment_Date, a.Status,       p.name AS Patient_Name,       d.name as doctornameFROM Appointments aJOIN patient_s p ON a.Patient_ID = p.Patient_IDJOIN Doctors d ON a.Doctor_ID = d.Doctor_IDWHERE a.Appointment_Date >= '04/05/2023'  /*or getdate() ...we can use for future appointment*//* What is the cancellation rate? */SELECT     (CAST(SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS Cancellation_RateFROM Appointments;SELECT  
    (COUNT(CASE WHEN status = 'Cancelled' THEN 1 END) * 100.0 / COUNT(*)) AS Cancellation_Rate  
FROM appointments;
/* 	Medical Records Management
Question: Retrieve a full medical history for a patient */select *from medical_recordsselect *from medical_records as mjoin doctors as don m.doctor_id=d.doctor_idjoin patient_s as pon m.patient_id=p.patient_idwhere p.name='Sarah Miller';/*	Billing & Payment Management
Question: What is the total revenue collected? */select *from billing;select sum(total_amount) as total_revenuefrom billingwhere  payment_status='paid';
/*What are the outstanding (pending) payments?*/

select bill_id,patient_id,total_amount,payment_date
from billing
where payment_status='pending';

/*  	Operational & Data Integrity Checks
Question: How many records in a table have null values in critical fields?*/



