-- Tạo bảng
CREATE TABLE patients (
	patient_id SERIAL PRIMARY KEY,
	full_name VARCHAR(100),
	phone VARCHAR(20),
	city VARCHAR(50),
	symptoms TEXT[]
);

CREATE TABLE doctors (
	doctor_id SERIAL PRIMARY KEY,
	full_name VARCHAR(100),
	department VARCHAR(50)
);

CREATE TABLE appointments (
	appointment_id SERIAL PRIMARY KEY,
	patient_id INT REFERENCES patients(patient_id),
	doctor_id INT REFERENCES doctors(doctor_id),
	appointment_date DATE,
	diagnosis VARCHAR(200),
	fee NUMERIC(10,2)
);

-- 1. Chèn dữ liệu mẫu
INSERT INTO patients (full_name, phone, city, symptoms) VALUES
('Nguyen Van A', '0901000001', 'HCM', ARRAY['fever','cough']),
('Tran Thi B', '0901000002', 'Ha Noi', ARRAY['headache','fever']),
('Le Van C', '0901000003', 'Da Nang', ARRAY['stomachache']),
('Pham Thi D', '0901000004', 'Can Tho', ARRAY['cough','sore throat']),
('Hoang Van E', '0901000005', 'Hai Phong', ARRAY['fatigue','fever']);

INSERT INTO doctors (full_name, department) VALUES
('Dr. An', 'Cardiology'),
('Dr. Binh', 'Neurology'),
('Dr. Cuong', 'General'),
('Dr. Dung', 'ENT'),
('Dr. Em', 'Internal');

INSERT INTO appointments (patient_id, doctor_id, appointment_date, diagnosis, fee) VALUES
(1,1,'2025-01-01','Flu',300.00),
(1,3,'2025-01-10','General Check',500.00),
(2,2,'2025-01-02','Migraine',700.00),
(2,3,'2025-01-11','Fever',400.00),
(3,3,'2025-01-03','Gastritis',800.00),
(3,5,'2025-01-12','Follow up',350.00),
(4,4,'2025-01-04','Throat Infection',450.00),
(4,3,'2025-01-13','Cough',300.00),
(5,5,'2025-01-05','Fatigue',900.00),
(5,1,'2025-01-14','Heart Check',1200.00);

-- 2a. B-tree cho phone
CREATE INDEX idx_patients_phone
ON patients (phone);

-- 2b. Hash cho city
CREATE INDEX idx_patients_city_hash
ON patients USING HASH (city);

-- 2c. GIN cho symptoms
CREATE INDEX idx_patients_symptoms_gin
ON patients USING GIN (symptoms);

-- 2d. GiST cho fee
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE INDEX idx_appointments_fee_gist
ON appointments USING GIST (fee);

-- 3. Clustered Index trên appointments theo appointment_date
CREATE INDEX idx_appointments_date
ON appointments (appointment_date);

CLUSTER appointments USING idx_appointments_date;

-- 4a. Top 3 bệnh nhân có tổng phí khám cao nhất
SELECT p.patient_id,
       p.full_name,
       SUM(a.fee) AS total_fee
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.full_name
ORDER BY total_fee DESC
LIMIT 3;

-- 4b. Tổng số lượt khám theo bác sĩ
SELECT d.doctor_id,
       d.full_name,
       COUNT(a.appointment_id) AS total_appointments
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.full_name
ORDER BY total_appointments DESC;

-- 5. View có thể cập nhật city
CREATE VIEW v_patient_city AS
SELECT patient_id, full_name, city
FROM patients
WITH CHECK OPTION;

-- 5a. Cập nhật thành phố qua view
UPDATE v_patient_city
SET city = 'Hue'
WHERE patient_id = 1;

SELECT * FROM patients WHERE patient_id = 1;