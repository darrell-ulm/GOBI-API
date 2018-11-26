﻿SELECT
--b. and v. abbreviations must be consistent throughout
(regexp_matches(
	v.field_content,
	'[0-9]{9,10}[x]{0,1}|[0-9]{12,13}[x]{0,1}', --regex borrowed from PLCH (Ray Voelker)
	'i'
	)
)[1] as clean_isbn

FROM
sierra_view.bib_record AS b
JOIN
sierra_view.bib_record_location AS loc
ON
b.record_id = loc.bib_record_id
JOIN
sierra_view.varfield_view AS v
ON
b.id = v.record_id
JOIN
sierra_view.record_metadata AS m  
ON
b.record_id = m.id  

WHERE
  m.record_type_code = 'b'  --need to limit to type code 'o'
AND
  m.creation_date_gmt >  (now() - interval '8 days') --for initial load remove time limit
AND
  v.marc_tag = '020' --ISBNs 
AND
  b.is_suppressed = 'FALSE'
AND
  b.bcode2 != '@' --excluding ebooks
AND 
  m.campus_code = '' --excluding virtual records
AND
  loc.location_code NOT LIKE 'h%' --excluding hamilton
AND
  loc.location_code NOT LIKE 'm%' --excluding middletown

ORDER by clean_isbn ASC

