
CREATE TABLE Customers (
    customer_id TEXT PRIMARY KEY,
    signup_date TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    email TEXT NOT NULL UNIQUE
);

CREATE TABLE Region (
    area_id INTEGER PRIMARY KEY AUTOINCREMENT, 
    post_code TEXT NOT NULL UNIQUE CHECK (LENGTH(post_code) BETWEEN 2 AND 10),
    area_name TEXT NOT NULL,
    country TEXT NOT NULL DEFAULT 'UK'
);

CREATE TABLE Products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,  
    sku TEXT NOT NULL,  
    product TEXT NOT NULL,  
    standard_cost REAL NOT NULL CHECK (standard_cost >= 0),  
    list_price REAL NOT NULL CHECK (list_price >= standard_cost),  
    brand TEXT NOT NULL,  
    subcategory TEXT NOT NULL,
    category TEXT NOT NULL
);

CREATE TABLE Order_Items (
    order_item_id TEXT PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price REAL NOT NULL CHECK (price > 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

CREATE TABLE Payments (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    payment_date TEXT NOT NULL,
    payment_method TEXT NOT NULL CHECK (payment_method IN ('PayPal', 'Debit Card', 'Credit Card', 'Apple Pay', 'Refund')),
    payment_status TEXT NOT NULL CHECK (payment_status IN ('Completed', 'Refund')),
    amount_paid REAL NOT NULL CHECK (amount_paid > 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
);

CREATE TABLE Shipping (
    shipment_id TEXT PRIMARY KEY,  
    order_id INTEGER NOT NULL,  
    shipping_cost REAL NOT NULL CHECK (shipping_cost > 0),  
    shipment_date TEXT NOT NULL,  
    delivery_date TEXT NOT NULL,
    area_id INTEGER NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
    FOREIGN KEY (area_id) REFERENCES Region(area_id) ON DELETE SET NULL
);

CREATE TABLE Returns (
    return_id INTEGER PRIMARY KEY AUTOINCREMENT,  
    order_id INTEGER NOT NULL,  
    product_id INTEGER NOT NULL,  
    return_reason TEXT,
    return_date TEXT NOT NULL,  
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE SET NULL
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE SET NULL
);

CREATE TABLE Stock_Purchases (
    purchase_id TEXT PRIMARY KEY,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    purchase_date TEXT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE NULL
);

CREATE TABLE Orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id TEXT NOT NULL,
    order_date TEXT NOT NULL,
    order_status TEXT NOT NULL CHECK (order_status IN ('Pending', 'Delivered', 'Cancelled', 'Processing')),
    subtotal REAL NOT NULL CHECK (subtotal >= 0),
    shipping_cost REAL CHECK (COALESCE(shipping_cost, 0) >= 0),
    discount REAL CHECK (COALESCE(discount, 0) BETWEEN 0 AND 1),
    total_amount REAL NOT NULL CHECK (total_amount >= 0),
    shipping_id TEXT UNIQUE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (shipping_id) REFERENCES Shipping(shipment_id) ON DELETE SET NULL,
    CHECK (total_amount = subtotal * (1- COALESCE(discount, 0)) + COALESCE(shipping_cost, 0))
);