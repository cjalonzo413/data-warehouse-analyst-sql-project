--1. how many dogs were successfully screened? 12
--count dogs with valid screening form_completion_date
SELECT count(*) as screened_count
FROM screening_form
WHERE form_completion_date is not null
	AND trim(form_completion_date) <> '';

--2. eligible dogs? 4
--dogs are eligibile if all elig_questions = 1 and all inelig_questions are not 1 and not null
SELECT count(*) as eligible_count
FROM screening_form
WHERE elig_question_1 == 1
	AND elig_question_2 == 1
	AND elig_question_3 ==1
	AND inelig_question_1 is not null
	AND inelig_question_1 != 1
	AND inelig_question_2 is not null
	AND inelig_question_2 != 1;

--2a. missing allowed? 7
--allowing missing values on ineligibility questions
SELECT count(*) as eligible_count_missing_allowed
FROM screening_form
WHERE elig_question_1 = 1
	AND elig_question_2 = 1
	AND elig_question_3 = 1
	AND (inelig_question_1 IS NULL OR inelig_question_1 != 1)
	AND (inelig_question_2 IS NULL OR inelig_question_2 != 1);

--3. ready for enrollment? 4
--must be eligible and withdrawl_status not 1 or 2
SELECT count(*) as eligible_count
FROM screening_form s
LEFT JOIN request_to_withdraw_form r on r.id = s.id
WHERE elig_question_1 == 1
	AND elig_question_2 == 1
	AND elig_question_3 == 1
	AND inelig_question_1 is not null
	AND inelig_question_1 != 1
	AND inelig_question_2 is not null
	AND inelig_question_2 != 1
	AND (r.withdrawal_status is null or r.withdrawal_status not in (1,2));

--4. dogs withdrawn? 2
--count of withdrawl_status as 1 or 2
SELECT count(*) as withdrawn_count
FROM request_to_withdraw_form
WHERE withdrawal_status in (1,2);

--5. screened dogs older than 5? 6
--dogs with a form_completion_date and older than 5 years
SELECT count(*) as screened_older_than_5
FROM screening_form s
LEFT JOIN participant_info p on p.id = s.id
WHERE s.form_completion_date is not null
	AND (julianday(s.form_completion_date) - julianday(p.date_of_birth)) / 365.25 > 5;

--6. order to contact those ready to enroll starting with oldest form completion date
SELECT p.id, p.name, s.form_completion_date
FROM screening_form s
LEFT JOIN participant_info p on p.id = s.id
LEFT JOIN request_to_withdraw_form r on r.id = s.id
WHERE elig_question_1 == 1
	AND elig_question_2 == 1
	AND elig_question_3 ==1
	AND inelig_question_1 is not null
	AND inelig_question_1 != 1
	AND inelig_question_2 is not null
	AND inelig_question_2 != 1
	AND (r.withdrawal_status is null or r.withdrawal_status not in (1,2))
ORDER BY date(form_completion_date) asc;
