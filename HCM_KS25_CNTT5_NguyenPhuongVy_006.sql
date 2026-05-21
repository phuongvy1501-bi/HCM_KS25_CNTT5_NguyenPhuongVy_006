CREATE DATABASE IF NOT EXISTS academic_management_006;
USE academic_management_006;

-- PHẦN 1
CREATE TABLE IF NOT EXISTS courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    course_code VARCHAR(50) NOT NULL UNIQUE,
    department VARCHAR(100) NOT NULL,
    creation_date DATE
    );

CREATE TABLE IF NOT EXISTS students (
    student_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    major VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) NOT NULL UNIQUE,
    gpa DECIMAL(3, 1) DEFAULT 4.0,
    CONSTRAINT check_student_gpa CHECK (gpa >= 0.0 AND gpa <= 4.0)
);

CREATE TABLE IF NOT EXISTS enrollments (
    enrollment_id INT PRIMARY KEY,
    course_id INT,
    student_id INT,
    enroll_time DATETIME NOT NULL,
    credits INT,
    status ENUM('Pending', 'Completed', 'Dropped') DEFAULT 'Pending',
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    CONSTRAINT check_credits CHECK (credits > 0)
);

CREATE TABLE IF NOT EXISTS enrollment_details (
    detail_id INT PRIMARY KEY,
    enrollment_id INT,
    attendance_check VARCHAR(100) NOT NULL,
    detail_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id)
);

CREATE TABLE IF NOT EXISTS academic_logs (
    log_id INT PRIMARY KEY,
    detail_id INT,
    student_id INT,
    log_time DATETIME NOT NULL,
    note TEXT,
    FOREIGN KEY (detail_id) REFERENCES enrollment_details(detail_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);
-- PHẦN 2
-- CÂU 1
INSERT INTO courses (course_id, course_name, course_code, department, creation_date) VALUES
(1, 'Lập trình Java', 'JAVA01', 'CNTT', '2023-12-03'),
(2, 'Cấu trúc dữ liệu', 'DSA02', 'Khoa học máy tính', '1996-11-25'),
(3, 'Cơ sở dữ liệu', 'SQL03', 'CNTT', '2001-07-08'),
(4, 'Mạng máy tính', 'NET04', 'Truyền thông', '1998-01-19'),
(5, 'Trí tuệ nhân tạo', 'AI05', 'Khoa học máy tính', '2000-09-30');

INSERT INTO students (student_id, full_name, major, phone_number, gpa) VALUES
(1, 'Nguyễn Văn Hải', 'Hệ thống TT', '0931112223', 3.8),
(2, 'Trần Thu Hà', 'Kỹ thuật PM', '0932223334', 4.0),
(3, 'Lê Quốc Tuấn', 'An toàn TT', '0933334445', 3.6),
(4, 'Phạm Minh Châu', 'Dữ liệu lớn', '0934445556', 3.9),
(5, 'Hoàng Gia Bảo', 'Kỹ thuật PM', '0935556667', 3.7);

INSERT INTO enrollments (enrollment_id, course_id, student_id, enroll_time, credits, status) VALUES
(7001, 1, 1, '2024-05-20 08:00:00', 3, 'Pending'),
(7002, 2, 2, '2024-05-20 09:30:00', 4, 'Completed'),
(7003, 3, 3, '2024-05-20 10:15:00', 3, 'Pending'),
(7004, 4, 5, '2024-05-21 07:00:00', 3, 'Completed'),
(7005, 5, 4, '2024-05-21 08:45:00', 4, 'Dropped');

INSERT INTO enrollment_details (detail_id, enrollment_id, attendance_check, detail_date) VALUES
(8001, 7002, 'Đủ điều kiện thi', '2024-05-20 10:00:00'),
(8002, 7004, 'Vắng 1 buổi', '2024-05-21 08:00:00'),
(8003, 7001, 'Đang học', '2024-05-20 09:00:00'),
(8004, 7003, 'Nghỉ phép', '2024-05-20 11:00:00'),
(8005, 7005, 'Không đi học', '2024-05-21 09:00:00');

INSERT INTO academic_logs (log_id, detail_id, student_id, log_time, note) VALUES
(1, 8003, 1, '2024-05-20 09:05:00', 'Bắt đầu lớp học'),
(2, 8001, 2, '2024-05-20 10:05:00', 'Hoàn tất môn học'),
(3, 8004, 3, '2024-05-20 11:10:00', 'Đang sắp xếp lịch bù'),
(4, 8002, 5, '2024-05-21 08:10:00', 'Chờ phê duyệt điểm'),
(5, 8005, 4, '2024-05-21 09:05:00', 'Hủy do vắng quá số buổi');
-- CÂU 2
UPDATE enrollments e
JOIN courses c ON e.course_id = c.course_id
SET e.credits = e.credits + 1
WHERE e.status = 'Completed' 
  AND YEAR(c.creation_date) < 2000;

DELETE FROM academic_logs
WHERE DATE(log_time) < '2024-05-20';
-- PHẦN 3
-- CÂU 1
SELECT full_name, major, gpa 
FROM students 
WHERE gpa > 3.8 OR major = 'Kỹ thuật PM';

-- CÂU 2
SELECT course_name, course_code 
FROM courses 
WHERE creation_date BETWEEN '1998-01-01' AND '2001-12-31' 
  AND course_code LIKE 'A%';

-- CÂU 3
SELECT enrollment_id, enroll_time, credits 
FROM enrollments 
ORDER BY credits DESC 
LIMIT 2 OFFSET 2;
-- PHẦN 4
-- CÂU 1
SELECT 
    c.course_name, 
    s.full_name, 
    s.major, 
    e.credits, 
    e.enroll_time
FROM enrollments e
JOIN courses c ON e.course_id = c.course_id
JOIN students s ON e.student_id = s.student_id;

-- CÂU 2
SELECT 
    s.full_name, 
    SUM(e.credits) AS total_credits
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
WHERE e.status = 'Completed'
GROUP BY s.student_id, s.full_name
HAVING SUM(e.credits) > 120;

-- CÂU 3
SELECT student_id, full_name, gpa
FROM students
WHERE gpa = (SELECT MAX(gpa) FROM students);

-- PHẦN 5
-- CÂU 1
CREATE INDEX idx_enrollment_status_credits 
ON enrollments (status, credits);

-- CÂU 2
CREATE VIEW vw_student_summary AS
SELECT 
    s.full_name, 
    COUNT(e.course_id) AS total_courses, 
    SUM(e.credits) AS total_credits
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
WHERE e.status != 'Dropped'
GROUP BY s.student_id, s.full_name;

-- PHẦN 6
DELIMITER //

-- CÂU 1
CREATE TRIGGER trg_enrollment_after_update
AFTER UPDATE ON enrollments
FOR EACH ROW
BEGIN
    DECLARE v_detail_id INT;
    
    IF NEW.status = 'Completed' AND OLD.status != 'Completed' THEN
        SELECT detail_id INTO v_detail_id
        FROM enrollment_details
        WHERE enrollment_id = NEW.enrollment_id
        LIMIT 1;
        
        IF v_detail_id IS NOT NULL THEN
            INSERT INTO academic_logs (log_id, detail_id, student_id, log_time, note)
            VALUES ((SELECT IFNULL(MAX(log_id), 0) + 1 FROM academic_logs x), v_detail_id, NEW.student_id, NOW(), 'Course completed');
        END IF;
    END IF;
END //

-- CÂU 2
CREATE TRIGGER trg_enrollment_after_insert
AFTER INSERT ON enrollments
FOR EACH ROW
BEGIN
    IF NEW.status = 'Completed' THEN
        UPDATE students
        SET gpa = LEAST(gpa + 0.1, 4.0)
        WHERE student_id = NEW.student_id;
    END IF;
END //

DELIMITER ;
