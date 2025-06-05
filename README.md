# IDT-Assignment2
Початковий запит:
![image](https://github.com/user-attachments/assets/76dcd542-5872-454f-83d9-479a0bd468d0)
Створимо індекси:

CREATE INDEX sales_personID_ind ON sales(SalesPersonID);
![image](https://github.com/user-attachments/assets/6a37e632-e964-4442-aa1c-220ac48e2358)

CREATE INDEX productID_ind ON sales(ProductID);

![image](https://github.com/user-attachments/assets/57e0ae30-b564-4a45-8020-77ed0c4a3b11)

CREATE INDEX productID_salesDate_ind ON sales(SalesDate, ProductID);

І замінеми YEAR() на WHERE SalesDate >= '2018-01-01' AND SalesDate < '2019-01-01'

![image](https://github.com/user-attachments/assets/070bbc75-9957-431d-aa5f-9825541f2ee9)

