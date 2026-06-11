-- Sample Data for Demo
-- Customer Order Processing Integration

-- Insert sample customers
INSERT INTO customers (customer_id, name, email, phone, credit_limit, status) VALUES
('CUST001', 'John Smith', 'john.smith@email.com', '+1-555-0101', 15000.00, 'ACTIVE'),
('CUST002', 'Sarah Johnson', 'sarah.j@email.com', '+1-555-0102', 20000.00, 'ACTIVE'),
('CUST003', 'Michael Brown', 'mbrown@email.com', '+1-555-0103', 10000.00, 'ACTIVE'),
('CUST004', 'Emily Davis', 'emily.davis@email.com', '+1-555-0104', 25000.00, 'ACTIVE'),
('CUST005', 'David Wilson', 'dwilson@email.com', '+1-555-0105', 12000.00, 'ACTIVE'),
('CUST006', 'Lisa Anderson', 'landerson@email.com', '+1-555-0106', 18000.00, 'ACTIVE'),
('CUST007', 'James Taylor', 'jtaylor@email.com', '+1-555-0107', 22000.00, 'ACTIVE'),
('CUST008', 'Jennifer Martinez', 'jmartinez@email.com', '+1-555-0108', 16000.00, 'ACTIVE'),
('CUST009', 'Robert Garcia', 'rgarcia@email.com', '+1-555-0109', 14000.00, 'ACTIVE'),
('CUST010', 'Mary Rodriguez', 'mrodriguez@email.com', '+1-555-0110', 19000.00, 'ACTIVE')
ON CONFLICT (customer_id) DO NOTHING;

-- Insert sample products
INSERT INTO products (product_id, name, description, price, category) VALUES
('PROD001', 'Laptop Pro 15"', 'High-performance laptop with 16GB RAM', 1299.99, 'Electronics'),
('PROD002', 'Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 'Accessories'),
('PROD003', 'USB-C Hub', '7-in-1 USB-C hub with HDMI', 49.99, 'Accessories'),
('PROD004', 'Monitor 27"', '4K UHD monitor', 399.99, 'Electronics'),
('PROD005', 'Keyboard Mechanical', 'RGB mechanical keyboard', 129.99, 'Accessories'),
('PROD006', 'Webcam HD', '1080p HD webcam', 79.99, 'Electronics'),
('PROD007', 'Headset Wireless', 'Noise-cancelling headset', 199.99, 'Electronics'),
('PROD008', 'Laptop Stand', 'Adjustable aluminum stand', 39.99, 'Accessories'),
('PROD009', 'External SSD 1TB', 'Portable SSD 1TB', 149.99, 'Storage'),
('PROD010', 'Docking Station', 'Universal docking station', 249.99, 'Accessories'),
('PROD011', 'Tablet 10"', 'Android tablet 10 inch', 299.99, 'Electronics'),
('PROD012', 'Stylus Pen', 'Precision stylus pen', 49.99, 'Accessories'),
('PROD013', 'Portable Charger', '20000mAh power bank', 59.99, 'Accessories'),
('PROD014', 'Cable Set', 'USB cable variety pack', 24.99, 'Accessories'),
('PROD015', 'Laptop Bag', 'Professional laptop bag', 69.99, 'Accessories'),
('PROD016', 'Desk Lamp LED', 'Adjustable LED desk lamp', 44.99, 'Office'),
('PROD017', 'Notebook Set', 'Premium notebook 3-pack', 19.99, 'Office'),
('PROD018', 'Pen Set', 'Professional pen set', 34.99, 'Office'),
('PROD019', 'Desk Organizer', 'Wooden desk organizer', 29.99, 'Office'),
('PROD020', 'Monitor Arm', 'Adjustable monitor arm', 89.99, 'Accessories')
ON CONFLICT (product_id) DO NOTHING;

-- Insert inventory data
INSERT INTO inventory (product_id, quantity, warehouse_location) VALUES
('PROD001', 50, 'Warehouse-A'),
('PROD002', 200, 'Warehouse-A'),
('PROD003', 150, 'Warehouse-A'),
('PROD004', 75, 'Warehouse-B'),
('PROD005', 100, 'Warehouse-A'),
('PROD006', 80, 'Warehouse-B'),
('PROD007', 60, 'Warehouse-B'),
('PROD008', 120, 'Warehouse-A'),
('PROD009', 90, 'Warehouse-B'),
('PROD010', 40, 'Warehouse-B'),
('PROD011', 65, 'Warehouse-A'),
('PROD012', 180, 'Warehouse-A'),
('PROD013', 110, 'Warehouse-B'),
('PROD014', 250, 'Warehouse-A'),
('PROD015', 85, 'Warehouse-A'),
('PROD016', 95, 'Warehouse-B'),
('PROD017', 300, 'Warehouse-A'),
('PROD018', 200, 'Warehouse-A'),
('PROD019', 140, 'Warehouse-B'),
('PROD020', 55, 'Warehouse-B')
ON CONFLICT (product_id, warehouse_location) DO NOTHING;

-- Insert sample orders
INSERT INTO orders (order_id, customer_id, order_date, total_amount, discount_amount, tax_amount, final_amount, status, payment_status, shipping_address) VALUES
('ORD001', 'CUST001', CURRENT_TIMESTAMP - INTERVAL '5 days', 1329.98, 0.00, 106.40, 1436.38, 'DELIVERED', 'PAID', '123 Main St, New York, NY 10001'),
('ORD002', 'CUST002', CURRENT_TIMESTAMP - INTERVAL '4 days', 479.98, 24.00, 36.48, 492.46, 'SHIPPED', 'PAID', '456 Oak Ave, Los Angeles, CA 90001'),
('ORD003', 'CUST003', CURRENT_TIMESTAMP - INTERVAL '3 days', 199.99, 0.00, 16.00, 215.99, 'PROCESSING', 'PAID', '789 Pine Rd, Chicago, IL 60601'),
('ORD004', 'CUST004', CURRENT_TIMESTAMP - INTERVAL '2 days', 649.97, 32.50, 49.40, 666.87, 'PROCESSING', 'PAID', '321 Elm St, Houston, TX 77001'),
('ORD005', 'CUST005', CURRENT_TIMESTAMP - INTERVAL '1 day', 299.99, 0.00, 24.00, 323.99, 'PENDING', 'PENDING', '654 Maple Dr, Phoenix, AZ 85001')
ON CONFLICT (order_id) DO NOTHING;

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES
('ORD001', 'PROD001', 1, 1299.99, 1299.99),
('ORD001', 'PROD002', 1, 29.99, 29.99),
('ORD002', 'PROD004', 1, 399.99, 399.99),
('ORD002', 'PROD008', 2, 39.99, 79.99),
('ORD003', 'PROD007', 1, 199.99, 199.99),
('ORD004', 'PROD001', 1, 1299.99, 1299.99),
('ORD004', 'PROD005', 1, 129.99, 129.99),
('ORD004', 'PROD009', 1, 149.99, 149.99),
('ORD005', 'PROD011', 1, 299.99, 299.99);

-- Insert audit log entries
INSERT INTO audit_log (entity_type, entity_id, action, user_id, changes) VALUES
('ORDER', 'ORD001', 'CREATED', 'system', '{"status": "PENDING"}'),
('ORDER', 'ORD001', 'UPDATED', 'system', '{"status": "PROCESSING"}'),
('ORDER', 'ORD001', 'UPDATED', 'system', '{"status": "SHIPPED"}'),
('ORDER', 'ORD001', 'UPDATED', 'system', '{"status": "DELIVERED"}'),
('ORDER', 'ORD002', 'CREATED', 'system', '{"status": "PENDING"}'),
('ORDER', 'ORD002', 'UPDATED', 'system', '{"status": "PROCESSING"}'),
('ORDER', 'ORD002', 'UPDATED', 'system', '{"status": "SHIPPED"}'),
('ORDER', 'ORD003', 'CREATED', 'system', '{"status": "PENDING"}'),
('ORDER', 'ORD003', 'UPDATED', 'system', '{"status": "PROCESSING"}'),
('ORDER', 'ORD004', 'CREATED', 'system', '{"status": "PENDING"}'),
('ORDER', 'ORD004', 'UPDATED', 'system', '{"status": "PROCESSING"}'),
('ORDER', 'ORD005', 'CREATED', 'system', '{"status": "PENDING"}');

-- Create a function to update inventory after order
CREATE OR REPLACE FUNCTION update_inventory_on_order()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE inventory
    SET quantity = quantity - NEW.quantity,
        last_updated = CURRENT_TIMESTAMP
    WHERE product_id = NEW.product_id
    AND quantity >= NEW.quantity;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Insufficient inventory for product %', NEW.product_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for inventory updates
DROP TRIGGER IF EXISTS trg_update_inventory ON order_items;
CREATE TRIGGER trg_update_inventory
    AFTER INSERT ON order_items
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_on_order();

-- Create a function to log audit trail
CREATE OR REPLACE FUNCTION log_audit_trail()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (entity_type, entity_id, action, user_id, changes)
    VALUES (
        TG_TABLE_NAME,
        COALESCE(NEW.order_id, NEW.customer_id, NEW.product_id),
        TG_OP,
        current_user,
        row_to_json(NEW)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Display summary
SELECT 'Database initialized successfully!' as status;
SELECT COUNT(*) as customer_count FROM customers;
SELECT COUNT(*) as product_count FROM products;
SELECT COUNT(*) as order_count FROM orders;
SELECT SUM(quantity) as total_inventory FROM inventory;

-- Made with Bob
