/*Charlie's Chocolate Factory company produces chocolates. The following product information is stored:
product name, product ID, and quantity on hand. 

These chocolates are made up of many components.
Each component can be supplied by one or more suppliers. 
The following component information is kept: component ID, name, description, quantity on hand, 
suppliers who supply them, when and how much they supplied, and products in which they are used.
On the other hand following supplier information is stored: supplier ID, name, and activation status.
Assumptions
A supplier can exist without providing components.
A component does not have to be associated with a supplier. It may already have been in the inventory.
A component does not have to be associated with a product. Not all components are used in products.
A product cannot exist without components.*/

CREATE DATABASE Charlie_Chocolate_Factory


CREATE TABLE Product_table

(product_name VARCHAR(255),
product_ID int PRIMARY KEY,
quantity INT
);

CREATE TABLE product_component_table
(product_ID int PRIMARY KEY ,
component_id int 
);



CREATE TABLE component_table
( component_ID INT PRIMARY KEY ,
  [name] VARCHAR(255),
 [description] TEXT,
quantity INT
);

CREATE TABLE  suppliers_of_components
(
supplier_date DATE,
supplied_amount INT,
products_usage VARCHAR(255),
supplier_id INT PRIMARY KEY,
component_ID INT 
);


CREATE TABLE suppliers
(supplier_name VARCHAR(255),
supplier_id INT PRIMARY KEY,
activation_status VARCHAR(255)
);

  
  
  
CREATE TABLE product (
    product_ID INT IDENTITY (1, 1) PRIMARY KEY,
    product_name VARCHAR (200) NOT NULL,
    quantity INT
);
CREATE TABLE suppliers (
    supplier_ID INT IDENTITY (1, 1) PRIMARY KEY,
    [name] VARCHAR (200) NOT NULL,
    activation_status INT NULL
);
CREATE TABLE components (
    component_ID INT IDENTITY (1, 1) PRIMARY KEY,
    [name] VARCHAR (200) NOT NULL,
    [description] VARCHAR (200),
    quantity INT
);
CREATE TABLE product_component (
    component_ID INT,
    product_ID INT,
	FOREIGN KEY (component_ID)
	REFERENCES components (component_ID),
	FOREIGN KEY (product_ID)
	REFERENCES product (product_ID)
);
CREATE TABLE component_suppliers (
    component_ID INT,
    supplier_ID INT,
    supplied_date DATE NOT NULL,
    suplied_amount INT,
    FOREIGN KEY (component_ID)
    REFERENCES components (component_ID),
    FOREIGN KEY (supplier_ID)
    REFERENCES suppliers (supplier_ID)
	);